// Independent C++20 verifier for R003.
// It intentionally does not share the Python verifier's model semantics.
// Instead it parses and evaluates the frozen INDUSTRIAL_8 constraint text.

#include <algorithm>
#include <cassert>
#include <cctype>
#include <fstream>
#include <functional>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>

using Row = std::vector<std::string>;

static std::string trim(std::string s) {
    auto not_space = [](unsigned char c) { return !std::isspace(c); };
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), not_space));
    s.erase(std::find_if(s.rbegin(), s.rend(), not_space).base(), s.end());
    return s;
}

static std::vector<std::string> split_csv_line(const std::string& line) {
    std::vector<std::string> out;
    std::string cur;
    bool quoted = false;
    for (size_t i = 0; i < line.size(); ++i) {
        char c = line[i];
        if (c == '"') {
            quoted = !quoted;
        } else if (c == ',' && !quoted) {
            out.push_back(cur);
            cur.clear();
        } else {
            cur.push_back(c);
        }
    }
    out.push_back(cur);
    return out;
}

struct ParsedModel {
    std::vector<std::string> names;
    std::vector<std::vector<std::string>> domains;
    std::vector<std::string> constraints;
};

static ParsedModel parse_model_file(const std::string& path) {
    std::ifstream in(path);
    if (!in) throw std::runtime_error("cannot open " + path);

    ParsedModel m;
    enum class Section { None, Parameter, Constraint };
    Section section = Section::None;
    std::string line;

    while (std::getline(in, line)) {
        std::string t = trim(line);
        if (t.empty() || t.rfind("--", 0) == 0) continue;
        if (t == "[Parameter]") { section = Section::Parameter; continue; }
        if (t == "[Constraint]") { section = Section::Constraint; continue; }
        if (!t.empty() && t.front() == '[') { section = Section::None; continue; }

        if (section == Section::Parameter) {
            auto colon = t.find(':');
            auto paren = t.find('(');
            if (colon == std::string::npos || paren == std::string::npos) {
                throw std::runtime_error("bad parameter line: " + t);
            }
            std::string name = trim(t.substr(0, paren));
            std::string rhs = t.substr(colon + 1);
            std::vector<std::string> values;
            std::stringstream ss(rhs);
            std::string item;
            while (std::getline(ss, item, ',')) values.push_back(trim(item));
            m.names.push_back(name);
            m.domains.push_back(values);
        } else if (section == Section::Constraint) {
            m.constraints.push_back(t);
        }
    }

    if (m.names.size() != 14 || m.constraints.empty()) {
        throw std::runtime_error("unexpected model shape");
    }
    for (int i = 0; i < 14; ++i) {
        if (m.names[i] != "p" + std::to_string(i + 1)) {
            throw std::runtime_error("unexpected parameter order");
        }
    }
    return m;
}

class ExprParser {
public:
    ExprParser(const std::string& text, const ParsedModel& model, const Row& row)
        : s_(text), model_(model), row_(row) {}

    bool parse() {
        bool v = parse_or();
        skip_ws();
        if (pos_ != s_.size()) {
            throw std::runtime_error("unparsed expression suffix: " + s_.substr(pos_));
        }
        return v;
    }

private:
    const std::string& s_;
    const ParsedModel& model_;
    const Row& row_;
    size_t pos_ = 0;

    void skip_ws() {
        while (pos_ < s_.size() && std::isspace(static_cast<unsigned char>(s_[pos_]))) ++pos_;
    }

    bool match(const std::string& tok) {
        skip_ws();
        if (s_.compare(pos_, tok.size(), tok) == 0) {
            pos_ += tok.size();
            return true;
        }
        return false;
    }

    void expect(const std::string& tok) {
        if (!match(tok)) throw std::runtime_error("expected token " + tok + " in " + s_);
    }

    bool parse_or() {
        bool v = parse_unary();
        while (true) {
            size_t save = pos_;
            if (!match("||")) {
                pos_ = save;
                return v;
            }
            bool rhs = parse_unary();
            v = v || rhs;
        }
    }

    bool parse_unary() {
        skip_ws();
        if (match("!")) return !parse_unary();
        if (match("(")) {
            bool v = parse_or();
            expect(")");
            return v;
        }
        return parse_comparison();
    }

    std::string parse_identifier() {
        skip_ws();
        size_t start = pos_;
        if (pos_ >= s_.size() || !std::isalpha(static_cast<unsigned char>(s_[pos_]))) {
            throw std::runtime_error("expected identifier in " + s_);
        }
        ++pos_;
        while (pos_ < s_.size() &&
               (std::isalnum(static_cast<unsigned char>(s_[pos_])) || s_[pos_] == '_')) {
            ++pos_;
        }
        return s_.substr(start, pos_ - start);
    }

    std::string parse_value() {
        skip_ws();
        if (pos_ < s_.size() && s_[pos_] == '"') {
            ++pos_;
            size_t start = pos_;
            while (pos_ < s_.size() && s_[pos_] != '"') ++pos_;
            if (pos_ >= s_.size()) throw std::runtime_error("unterminated string");
            std::string v = s_.substr(start, pos_ - start);
            ++pos_;
            return v;
        }
        return parse_identifier();
    }

    bool parse_comparison() {
        std::string name = parse_identifier();
        bool neq = false;
        if (match("!=")) neq = true;
        else expect("=");
        std::string value = parse_value();

        auto it = std::find(model_.names.begin(), model_.names.end(), name);
        if (it == model_.names.end()) throw std::runtime_error("unknown parameter " + name);
        size_t idx = static_cast<size_t>(it - model_.names.begin());
        bool equal = row_.at(idx) == value;
        return neq ? !equal : equal;
    }
};

static bool valid_by_parsed_model(const ParsedModel& model, const Row& row) {
    for (const auto& c : model.constraints) {
        ExprParser parser(c, model, row);
        if (!parser.parse()) return false;
    }
    return true;
}

static void enumerate_product(
    const ParsedModel& model, size_t idx, Row& row, std::vector<Row>& valid) {
    if (idx == model.domains.size()) {
        if (valid_by_parsed_model(model, row)) valid.push_back(row);
        return;
    }
    for (const auto& v : model.domains[idx]) {
        row.push_back(v);
        enumerate_product(model, idx + 1, row, valid);
        row.pop_back();
    }
}

static std::vector<Row> enumerate_valid(const ParsedModel& model) {
    std::vector<Row> valid;
    Row row;
    enumerate_product(model, 0, row, valid);
    return valid;
}

static std::vector<Row> read_suite_csv(const std::string& path,
                                       const std::vector<std::string>& expected_header) {
    std::ifstream in(path);
    if (!in) throw std::runtime_error("cannot open " + path);
    std::string line;
    if (!std::getline(in, line)) throw std::runtime_error("empty CSV " + path);
    auto header = split_csv_line(line);
    if (header != expected_header) throw std::runtime_error("bad CSV header in " + path);

    std::vector<Row> rows;
    std::set<Row> unique;
    while (std::getline(in, line)) {
        if (trim(line).empty()) continue;
        Row row = split_csv_line(line);
        if (row.size() != expected_header.size()) throw std::runtime_error("bad CSV row");
        if (!unique.insert(row).second) throw std::runtime_error("duplicate CSV row");
        rows.push_back(std::move(row));
    }
    return rows;
}

static void combinations_rec(int n, int k, int start, std::vector<int>& cur,
                             std::vector<std::vector<int>>& out) {
    if (static_cast<int>(cur.size()) == k) {
        out.push_back(cur);
        return;
    }
    for (int i = start; i <= n - (k - static_cast<int>(cur.size())); ++i) {
        cur.push_back(i);
        combinations_rec(n, k, i + 1, cur, out);
        cur.pop_back();
    }
}

static std::vector<std::vector<int>> combinations(int n, int k) {
    std::vector<std::vector<int>> out;
    std::vector<int> cur;
    combinations_rec(n, k, 0, cur, out);
    return out;
}

static std::string interaction_key(const Row& row, const std::vector<int>& cols) {
    std::ostringstream out;
    for (int c : cols) out << c << '=' << row.at(c) << ';';
    return out.str();
}

static std::set<std::string> interaction_set(const std::vector<Row>& rows, int t) {
    auto combos = combinations(14, t);
    std::set<std::string> out;
    for (const auto& row : rows) {
        for (const auto& cols : combos) out.insert(interaction_key(row, cols));
    }
    return out;
}

static std::string category(const Row& row) {
    if (row.at(12) == "false") return "p13=false";
    int false_count = 0;
    int false_index = -1;
    for (int i = 4; i < 12; ++i) {
        if (row.at(i) == "false") {
            ++false_count;
            false_index = i;
        }
    }
    if (false_count == 1) return "p" + std::to_string(false_index + 1) + "=false";
    if (false_count == 0) return "residual-all-true";
    return "invalid";
}

// Encode the r-way interaction universe on four binary columns in <= 64 bits.
static std::vector<unsigned long long> local_word_masks(int r, unsigned long long& full) {
    auto cols = combinations(4, r);
    std::map<std::pair<std::vector<int>, int>, int> bit_index;
    int bit = 0;
    for (const auto& c : cols) {
        for (int assignment = 0; assignment < (1 << r); ++assignment) {
            bit_index[{c, assignment}] = bit++;
        }
    }
    if (bit > 64) throw std::runtime_error("local universe too large");
    full = (bit == 64) ? ~0ULL : ((1ULL << bit) - 1ULL);

    std::vector<unsigned long long> masks(16, 0);
    for (int word = 0; word < 16; ++word) {
        for (const auto& c : cols) {
            int assignment = 0;
            for (int j = 0; j < r; ++j) {
                int value = (word >> (3 - c[j])) & 1;
                assignment = (assignment << 1) | value;
            }
            masks[word] |= 1ULL << bit_index[{c, assignment}];
        }
    }
    return masks;
}

static int popcount16(unsigned x) {
#if defined(__GNUG__)
    return __builtin_popcount(x);
#else
    int c = 0;
    while (x) { c += x & 1U; x >>= 1U; }
    return c;
#endif
}

static int exact_local_minimum(int r) {
    unsigned long long full = 0;
    auto word_masks = local_word_masks(r, full);
    int best = 17;
    for (unsigned subset = 0; subset < (1U << 16); ++subset) {
        int size = popcount16(subset);
        if (size >= best) continue;
        unsigned long long covered = 0;
        for (int w = 0; w < 16; ++w) {
            if (subset & (1U << w)) covered |= word_masks[w];
        }
        if (covered == full) best = size;
    }
    return best;
}

static void verify_class_structure(const std::vector<Row>& valid) {
    std::map<std::string, int> counts;
    std::map<std::string, std::set<std::string>> bit_patterns;
    for (const auto& row : valid) {
        std::string c = category(row);
        ++counts[c];
        if (c != "residual-all-true") {
            bit_patterns[c].insert(row[0] + row[1] + row[2] + row[3]);
        }
    }
    for (int p = 5; p <= 13; ++p) {
        std::string c = "p" + std::to_string(p) + "=false";
        if (counts[c] != 16 || bit_patterns[c].size() != 16) {
            throw std::runtime_error("mandatory class structure failed for " + c);
        }
    }
    if (counts["residual-all-true"] != 15) {
        throw std::runtime_error("residual class must contain 15 rows");
    }
}

int main() {
    try {
        ParsedModel model = parse_model_file("INDUSTRIAL_8.txt");
        auto valid = enumerate_valid(model);
        if (valid.size() != 159) throw std::runtime_error("expected 159 valid configurations");
        verify_class_structure(valid);

        std::map<int, int> expected_size{{2,18},{3,45},{4,72},{5,144},{6,144}};
        std::map<int, int> expected_interactions{{2,326},{3,2168},{4,9374},{5,28192},{6,61272}};
        std::map<int, int> local_r{{2,1},{3,2},{4,3},{5,4},{6,4}};
        std::map<int, std::string> witness{{
            2,"industrial8_t2_opt18.csv"},
            {3,"industrial8_t3_opt45.csv"},
            {4,"industrial8_t4_opt72.csv"},
            {5,"industrial8_t5_opt144.csv"},
            {6,"industrial8_t6_opt144.csv"}};

        std::map<int, int> local_min;
        for (int r = 1; r <= 4; ++r) local_min[r] = exact_local_minimum(r);
        if (local_min != std::map<int,int>{{1,2},{2,5},{3,8},{4,16}}) {
            throw std::runtime_error("unexpected local covering minima");
        }

        for (int t = 2; t <= 6; ++t) {
            auto suite = read_suite_csv(witness[t], model.names);
            if (static_cast<int>(suite.size()) != expected_size[t])
                throw std::runtime_error("wrong witness size");
            for (const auto& row : suite) {
                if (!valid_by_parsed_model(model, row))
                    throw std::runtime_error("witness contains invalid row");
            }

            auto required = interaction_set(valid, t);
            if (static_cast<int>(required.size()) != expected_interactions[t])
                throw std::runtime_error("unexpected interaction count");
            auto covered = interaction_set(suite, t);
            for (const auto& x : required) {
                if (!covered.count(x)) throw std::runtime_error("missing required interaction");
            }

            std::map<std::string, int> suite_counts;
            for (const auto& row : suite) ++suite_counts[category(row)];
            int local = local_min[local_r[t]];
            for (int p = 5; p <= 13; ++p) {
                std::string c = "p" + std::to_string(p) + "=false";
                if (suite_counts[c] != local)
                    throw std::runtime_error("witness class count does not meet exact local minimum");
            }
            if (suite_counts["residual-all-true"] != 0)
                throw std::runtime_error("witness unexpectedly uses residual rows");

            int lower_bound = 9 * local;
            if (lower_bound != expected_size[t])
                throw std::runtime_error("global lower bound mismatch");

            std::cout << "PASS independent t=" << t << ": " << suite.size()
                      << " published rows cover all " << required.size()
                      << " valid interactions; exact lower bound "
                      << lower_bound << " is met.\n";
        }

        std::cout << "PASS independent parser evaluated the frozen model text directly.\n";
        std::cout << "PASS independent local subset search proves minima 2,5,8,16.\n";
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "FAIL: " << e.what() << "\n";
        return 1;
    }
}

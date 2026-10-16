package parse

import "core:fmt"
import "core:net"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strings"

Count :: struct {
	key:   string,
	value: int,
}

show_destination_count :: proc(rules: [dynamic]RuleItem) {
	counts: map[string]int
	defer delete(counts)

	for rule in rules {
		switch x in rule {
		case SettingRule:
			continue
		case FilterRule:
			if x.destination == "*" {
				continue
			}

			key := x.destination

			counts[key] += 1
		}
	}

	items := make([dynamic]Count)
	defer delete(items)

	for key, value in counts {
		append(&items, Count{key = key, value = value})
	}

	slice.sort_by(items[:], proc(a, b: Count) -> bool {
		return sort.compare_strings(a.key, b.key) == -1
	})

	for item in items {
		fmt.println(item)
	}
}

show_source_domains :: proc(rules: [dynamic]RuleItem) {
	host_set: map[string]struct{}
	defer delete(host_set)

	for rule in rules {
		switch x in rule {
		case SettingRule:
			continue
		case FilterRule:
			url := x.source

			_, host, _, queries, _ := net.split_url(url, context.allocator)
			defer delete(queries)

			parts := strings.split(host, ".")
			defer delete(parts)

			url = strings.join(parts[len(parts) - 2:len(parts)], ".")

			ok := url in host_set
			if !ok {
				host_set[url] = {}
				fmt.println(url)
			}
		}
	}
}

write_without_subdomain :: proc(rules: [dynamic]RuleItem) {
	filename := "output.txt"
	file, err := os.open(filename, os.File_Flags{.Write, .Create})
	if err != nil {
		fmt.printfln("Failed to write file: %s", filename)
		return
	}
	defer os.close(file)

	for rule in rules {
		switch x in rule {
		case SettingRule:
			s := fmt.tprintfln("%s %s %s", x.name, x.location, x.val)
			os.write(file, transmute([]u8)s)
		case FilterRule:
			url := x.source

			_, host, _, _, _ := net.split_url(url, context.allocator)

			parts := strings.split(host, ".")
			defer delete(parts)

			url = strings.join(parts[len(parts) - 2:len(parts)], ".")

			s := fmt.tprintfln("%s %s %s %s", url, x.destination, x.req_type, x.action_type)
			os.write(file, transmute([]u8)s)
		}
	}
}

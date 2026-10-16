package main

import "core:fmt"
import "core:mem"
import "core:os"

import "parse"

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}

			mem.tracking_allocator_destroy(&track)
		}
	}

	user_formatters := make(map[typeid]fmt.User_Formatter)
	defer delete(user_formatters)

	fmt.set_user_formatters(&user_formatters)
	fmt.register_user_formatter(type_info_of(parse.ReqKind).id, parse.ReqKind_Formatter)
	fmt.register_user_formatter(type_info_of(parse.ActionKind).id, parse.ActionKind_Formatter)

	filename := "input.txt"
	data, err := os.read_entire_file(filename, context.allocator)
	if err != nil {
		fmt.printfln("Failed to read file: %s", filename)
		return
	}
	defer delete(data, context.allocator)

	lexer := parse.lexer_init(data)
	parser := parse.parser_init(&lexer)

	rules, _ := parse.parser_parse(&parser)
	defer delete(rules)

	parse.show_destination_count(rules)
	// parse.show_source_domains(rules)
	// parse.write_without_subdomain(rules)
}

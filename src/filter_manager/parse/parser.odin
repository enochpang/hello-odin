package parse

import "core:fmt"

Error :: enum {
	ParseRequest,
	ParseAction,
	ParseUri,
	ParseLine,
}

Parser :: struct {
	lexer: ^Lexer,
	token: SyntaxToken,
}

//Returns the Parser struct.
parser_init :: proc(lexer: ^Lexer) -> Parser {
	token := lexer_next_token(lexer)

	return Parser{lexer = lexer, token = token}
}

//Processes all the tokens.
parser_parse :: proc(p: ^Parser, allocator := context.allocator) -> ([dynamic]RuleItem, Error) {
	rules := make([dynamic]RuleItem)

	for p.token.kind != .End {
		line_parts := parser_read_line(p)
		defer delete(line_parts)

		switch len(line_parts) {
		case 4:
			req_type: ReqKind
			switch line_parts[2] {
			case "*":
				req_type = .All
			case "image":
				req_type = .Image
			case "inline-script":
				req_type = .InlineScript
			case "1p-script":
				req_type = .FstpScript
			case "3p":
				req_type = .Thrdp
			case "3p-script":
				req_type = .ThrdpScript
			case "3p-frame":
				req_type = .ThrdpFrame
			case:
				fmt.println("Failed to get request type.")
				return nil, .ParseRequest
			}

			action_type: ActionKind
			switch line_parts[3] {
			case "block":
				action_type = .Block
			case "noop":
				action_type = .Noop
			case "allow":
				action_type = .Allow
			case:
				fmt.println("Failed to get action type.")
				return nil, .ParseAction
			}

			filter := FilterRule {
				source      = line_parts[0],
				destination = line_parts[1],
				req_type    = req_type,
				action_type = action_type,
			}

			append(&rules, filter)
		case 3:
			setting := SettingRule {
				name     = line_parts[0],
				location = line_parts[1],
				val      = line_parts[2],
			}

			append(&rules, setting)
		case:
			return nil, .ParseLine
		}
	}

	return rules, nil
}

//Returns a list of words in the next line.
parser_read_line :: proc(p: ^Parser, allocator := context.allocator) -> [dynamic]string {
	parts := make([dynamic]string)

	for p.token.kind != .Eol && p.token.kind != .End {
		append(&parts, p.token.text)
		parser_next(p)
	}

	//The eol or end.
	parser_next(p)

	return parts
}

//Move the parser to the next token.
parser_next :: proc(p: ^Parser) {
	p.token = lexer_next_token(p.lexer)
}

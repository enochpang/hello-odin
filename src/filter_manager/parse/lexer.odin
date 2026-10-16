package parse

Lexer :: struct {
	source:   []byte,
	offset:   int,
	rdoffset: int,
}

//Returns the Lexer struct.
lexer_init :: proc(input: []byte) -> Lexer {
	return Lexer{source = input}
}

//Returns the next token in the input.
lexer_next_token :: proc(l: ^Lexer) -> SyntaxToken {
	ch := lexer_advance(l)

	for ch == ' ' {
		l.offset = l.rdoffset
		ch = lexer_advance(l)
	}

	kind: SyntaxKind
	switch ch {
	case '\r', '\n':
		kind = lexer_scan_newline(l)
	case 0:
		kind = .End
	case:
		kind = lexer_scan_string(l)
	}

	text := string(l.source[l.offset:l.rdoffset])

	l.offset = l.rdoffset

	return SyntaxToken{kind = kind, text = text}
}

//Scan a string token.
lexer_scan_string :: proc(l: ^Lexer) -> SyntaxKind {
	loop: for {
		switch lexer_peek(l) {
		case ' ', '\r', '\n', 0:
			break loop
		case:
			lexer_advance(l)
		}
	}

	return .String
}

//Scan a newline token.
lexer_scan_newline :: proc(l: ^Lexer) -> SyntaxKind {
	loop: for {
		switch lexer_peek(l) {
		case '\r', '\n':
			lexer_advance(l)
		case:
			break loop
		}
	}

	return .Eol
}

//Consumes the next character in the lexer.
lexer_advance :: proc(l: ^Lexer) -> byte {
	if l.rdoffset >= len(l.source) {
		return 0
	} else {
		ch := l.source[l.rdoffset]
		l.rdoffset += 1
		return ch
	}
}

//Look ahead one character in the lexer.
lexer_peek :: proc(l: ^Lexer) -> byte {
	if l.rdoffset >= len(l.source) {
		return 0
	} else {
		return l.source[l.rdoffset]
	}
}

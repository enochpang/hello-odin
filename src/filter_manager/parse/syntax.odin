package parse

import "core:fmt"

//Represents a syntax item.
SyntaxToken :: struct {
	kind: SyntaxKind,
	text: string,
}

//Represents the type of syntax item.
SyntaxKind :: enum {
	String,
	Eol,
	End,
}

//Represents a rule entry.
RuleItem :: union #no_nil {
	FilterRule,
	SettingRule,
}

//Represents a filter rule item.
FilterRule :: struct {
	source:      string,
	destination: string,
	req_type:    ReqKind,
	action_type: ActionKind,
}

//Represents a setting rule item.
SettingRule :: struct {
	name:     string,
	location: string,
	val:      string,
}

//Represents the rule's type of request.
ReqKind :: enum {
	All,
	Image,
	InlineScript,
	FstpScript,
	Thrdp,
	ThrdpScript,
	ThrdpFrame,
}

//Represents the rule's type of action.
ActionKind :: enum {
	Block,
	Noop,
	Allow,
}

ReqKind_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> bool {
	m := cast(^ReqKind)arg.data
	switch verb {
	case 's':
		text: string
		switch m^ {
		case .All:
			text = "*"
		case .Image:
			text = "image"
		case .InlineScript:
			text = "inline-script"
		case .FstpScript:
			text = "1p-script"
		case .Thrdp:
			text = "3p"
		case .ThrdpScript:
			text = "3p-script"
		case .ThrdpFrame:
			text = "3p-frame"
		}

		fmt.fmt_string(fi, text, verb)
	case:
		return false
	}
	return true
}

ActionKind_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> bool {
	m := cast(^ActionKind)arg.data
	switch verb {
	case 's':
		text: string
		switch m^ {
		case .Block:
			text = "block"
		case .Noop:
			text = "noop"
		case .Allow:
			text = "allow"
		}

		fmt.fmt_string(fi, text, verb)
	case:
		return false
	}
	return true
}

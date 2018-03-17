
var root = null
var stack = [{
	name = 'doc',
	attr = {},
	text = '',
	children = []
}]
var parser = XMLParser.new()

func _init(string_content):
	parser.open_buffer(string_content.to_ascii())
	while parser.read() != ERR_FILE_EOF:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node = {
					name = parser.get_node_name(),
					attr = {},
					text = '',
					children = [],
				}
				for i in range(parser.get_attribute_count()):
					node.attr[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
				stack.front().children.append(node)
				stack.push_front(node)
				
			XMLParser.NODE_ELEMENT_END:
				stack.pop_front()
				
			XMLParser.NODE_TEXT:
				stack.front().text = parser.get_node_data()
	
	# xml _should_ have one base element
	root = stack.front().children.front()
	
func get_child_nodes(node, name):
	var found = []
	for child in node.children:
		if child.name == name:
			found.append(child)
	return found
	
func get_child_node(node, name, index):
	var found = get_child_nodes(node, name)
	if index >= 0 and index < found.size():
		return found[index]
	return null
	
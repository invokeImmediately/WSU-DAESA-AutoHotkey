class Trie {
	_children := Object()
	_node := ""
	_isEndOfWord := False

	__New(key, isEndOfWord) {
		this._node := key
		this._isEndOfWord := isEndOfWord
	}

	Insert(key) {
		length := StrLen(key)
		subTrie := this
		Loop, %length%
		{
			subKey := SubStr(key, 1, A_Index)
			isEndOfWord := A_Index == length
			child := (subTrie.children)[subKey]
			if (!child) {
				(subTrie.children)[subKey] := New Trie(subKey, isEndOfWord)
				subTrie := (subTrie.children)[subKey]
			} else {
				subTrie := child
				if (A_Index == length) {
					subTrie.isEndOfWord := True
				}
			}
		}
	}

	Search(key) {
		; Find a node within the trie
		length := StrLen(key)
		subTrie := this
		child := False
		Loop, %length%
		{
			subKey := SubStr(key, 1, A_Index)
			child := (subTrie.children)[subKey]
			if (!child) {
				Break
			} else {
				subTrie := child
			}
		}
		Return child
	}

	GetWordsArray(key := "") {
		wordsList :=False
		if (key == "" || key == this.node) {
			wordsList := Object()
			trieArray := this.children
			; Proceed only if node value is contained within key
			For key, subTrie in trieArray
			{
				if (subTrie.isEndOfWord) {
					wordsList.Push(subTrie.node)
				}
				childWordsList := subTrie.GetWordsArray()
				For key, value in childWordsList
				{
					wordsList.Push(value)				
				}
			}
		} else {
			subTrie := this.Search(key)
			if (subTrie) {
				wordsList := subTrie.GetWordsArray()
			}
		}
		return wordsList
	}
	children[]
	{
		get {
			return this._children
		}
		set {
			return this._children := value
		}
	}
	node[]
	{
		get {
			return this._node
		}
		set {
			return this._node := value
		}
	}
	isEndOfWord[]
	{
		get {
			return this._isEndOfWord
		}
		set {
			return value == True ? this._isEndOfWord := value : this._isEndOfWord := False
		}
	}
}

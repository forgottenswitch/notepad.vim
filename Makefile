shortcuts_txt = SHORTCUTS.txt

all: $(shortcuts_txt)

.PHONY: $(shortcuts_txt)
$(shortcuts_txt): rc.vim
	grep "Ctrl\|^\"=" $+ | \
		grep -v shortcuts | \
		grep -v '^"_'| \
		sed -e 's/^" //; s/^"== //; s/^"=//;' > $@

.PHONY: clean
clean:
	@rm $(shortcuts_txt) 2>/dev/null || true

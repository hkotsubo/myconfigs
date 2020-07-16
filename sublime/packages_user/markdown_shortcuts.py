import sublime
import sublime_plugin


import re


def toggle_format(s, delim_open, delim_close):
    if not delim_close:
        delim_close = delim_open
    r = re.compile(r'^{0}(.+){1}$'.format(re.escape(delim_open), re.escape(delim_close)))
    m = r.match(s)
    if m: # ver se a string está com o delimitador, e remove
        return m.group(1)
    # senão, coloca o delimitador
    return '{0}{1}{2}'.format(delim_open, s, delim_close)


class MarkdownDelimiterCommand(sublime_plugin.TextCommand):
    def delim_close(self):
        return None


    def add_delim(self, edit):
        added = False
        for region in self.view.sel():
            if not region.empty():
                # texto selecionado
                s = self.view.substr(region)
                # adiciona/remove delimitadores
                s = toggle_format(s, self.delim_open(), self.delim_close())
                # Replace texto selecionado
                self.view.replace(edit, region, s)
                added = True
        return added


    def run(self, edit):
        self.add_delim(edit)




class MarkdownBoldCommand(MarkdownDelimiterCommand):
    def delim_open(self):
        return '**'


class MarkdownItalicCommand(MarkdownDelimiterCommand):
    def delim_open(self):
        return '_'


class MarkdownAddLinkCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        def on_done(input_string):
            nf = self.view.window().active_view()
            nf.run_command('aux_add_link', { 'arg': input_string })


        window = self.view.window()
        window.show_input_panel("Link:", "", on_done, None, None)


class AuxAddLinkCommand(sublime_plugin.TextCommand):
    def run(self, edit, arg):
        for region in self.view.sel():
            if not region.empty():
                s = self.view.substr(region)
                s = '[{}]({})'.format(s, arg)
                self.view.replace(edit, region, s)


class MarkdownCodeCommand(MarkdownDelimiterCommand):
    def delim_open(self):
        return '`'


class MarkdownCodeBlockCommand(MarkdownDelimiterCommand):
    def delim_open(self):
        return "```\n"


    def delim_close(self):
        return "\n```\n"


    def run(self, edit):
        if not self.add_delim(edit):
            for region in self.view.sel():
                self.view.insert(edit, region.begin(), self.delim_open() + self.delim_close())
                self.view.sel().clear()
                self.view.sel().add(region.begin() + 4)


class MarkdownGenericListCommand(sublime_plugin.TextCommand):
    def mark(self):
        return ''


    def run(self, edit):
        for region in self.view.sel():
            if not region.empty():
                s = self.view.substr(region)
                self.view.replace(edit, region, "\n" + re.sub(r'^(.+)$', r'{} \1'.format(self.mark()), s, flags = re.M) + "\n")




class MarkdownListCommand(MarkdownGenericListCommand):
    def mark(self):
        return '-'


_count = 0
class MarkdownOrderedListCommand(MarkdownGenericListCommand):
    def run(self, edit):
        global _count
        _count = 0
        def repl(matchobj):
            global _count
            _count += 1
            return '{}. {}'.format(_count, matchobj.group(1))


        for region in self.view.sel():
            if not region.empty():
                s = self.view.substr(region)
                self.view.replace(edit, region, "\n" + re.sub(r'^(.+)$', repl, s, flags = re.M) + "\n")
 


class MarkdownQuoteCommand(MarkdownGenericListCommand):
    def mark(self):
        return '>'
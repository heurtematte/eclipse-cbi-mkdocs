from mkdocs.plugins import BasePlugin
import re


class FilterPlugin(BasePlugin):
    def on_page_markdown(self, markdown, **kwargs):        
        pattern = r'{{< toc >}}'
        filtered_markdown = re.sub(pattern, '', markdown, flags=re.DOTALL)
        return filtered_markdown

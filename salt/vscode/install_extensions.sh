{% for ext in extensions %}
code --install-extension {{ ext }}
{% endfor %}
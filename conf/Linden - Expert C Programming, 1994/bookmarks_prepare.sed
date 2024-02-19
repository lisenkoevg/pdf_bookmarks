/^\s*$/d
/^#/d
/Further Reading/d
s/“|”/"/g
s/’/'/g
s/Diagram (A|B|C)/Figure \1\./
s/(It May Be Crufty)(, but It's the Only Game in Town)/\1 \[4\]\2/
s/Appendix: //

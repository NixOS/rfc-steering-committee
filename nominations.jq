map(.
  | "(?<str>shep|nominat)" as $regex
  | select(.body | match($regex; "i"))
  | { body: .body | gsub($regex; "\u001b[31;1m" + .str + "\u001b[m"; "i"), author: .user.login }
  | .author + "\n---\n" + .body + "\n\n"
)
| add
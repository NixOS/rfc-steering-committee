if length >= 100 then
   error("Too many comments :( I can't deal with paging yet")
else
   map(.
     | "(?<str>shep|nominat)" as $regex
     | select(.body | match($regex; "i"))
     | { body: .body | gsub($regex; "\u001b[31;1m" + .str + "\u001b[m"), author: .user.login }
     | .author + "\n---\n" + .body + "\n\n"
   )
   | add
end
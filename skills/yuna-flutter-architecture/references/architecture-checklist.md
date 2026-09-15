# Architecture Quick Check

- Can the data/control flow be explained in a few steps?
- Is state ownership obvious?
- Is there one source of truth?
- Is UI free from business/data logic?
- Are raw transport/storage details leaking upward?
- Does each abstraction have real boundary value?
- Is shared code actually shared by reason-to-change?
- Are 3+ repeated UI patterns reviewed for reusable widgets?
- Can important behavior be tested without unnecessary Flutter runtime?
- Can the next cleanup be done as one small slice?

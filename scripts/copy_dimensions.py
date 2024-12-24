import glob
from shutil import rmtree, copy
from os import makedirs

base_dimension = ("world0", "WORLD_OVERWORLD")

dimensions = [
  ("world-1", "WORLD_THE_NETHER"),
  ("world1", "WORLD_THE_END")
]

excluded_programs = [
  "setup.csh",
  "setup1.csh",
  "prepare1.csh"
]


# clear out the dirs
for dimension in dimensions:
  try:
    rmtree(f"./shaders/{dimension[0]}")
  except Exception:
    pass

  makedirs(f"./shaders/{dimension[0]}")

# get list of programs
shader_programs = glob.glob(f"./shaders/{base_dimension[0]}/*")
shader_programs = [i.replace("\\", "/") for i in shader_programs]

# for each program, copy it to every other dimension's directory, and replace the name definition with relevant dimension name
for dimension in dimensions:
  for program in shader_programs:
    program_name = program.split("/")[-1]
    if program_name in excluded_programs:
      continue

    new_program = program.replace(base_dimension[0], dimension[0])
    copy(program, new_program)

    with open(new_program, "r+") as p:
      program_text = p.read()
      program_text = program_text.replace(base_dimension[1], dimension[1])
      p.seek(0)
      p.write(program_text)
      p.truncate()
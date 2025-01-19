import json
import glob
from shutil import rmtree, copy
from os import makedirs  

f = open("viewport.json", "r")
json_data = json.loads(f.read())
f.close()

def build_indexed_program(program: dict, index: int, stage: str, dimension: dict):
    for shader_pass in ["compute", "vertex", "fragment"]:
        if not shader_pass in program:
            continue
        
        extension = ""
        match shader_pass:
            case "compute":
                extension = ".csh"
            case "vertex":
                extension = ".vsh"
            case "fragment":
                extension = ".fsh"

        if index == 0:
            index = ""

        with open(f"./shaders/{dimension['folder']}/{stage}{index}{extension}", "w+") as target_pass:
            target_pass.write(f"#version {json_data['version']}\n")
            with open(f"./{json_data['global_header']}", "r") as header:
                target_pass.writelines(header.readlines())
                target_pass.write("\n")

            target_pass.write(f"#define {dimension['define']}\n")

            if "defines" in program:
                for define, val in program["defines"].items():
                    target_pass.write(f"#define {define} {val}\n")

            with open(f"./shaders/{program[shader_pass]}", "r") as source_pass:
                source_content = source_pass.readlines()
                target_pass.writelines(source_content)
                target_pass.write("\n")

def build_named_program(program: dict, program_name: str, dimension: dict):
    for shader_pass in ["compute", "vertex", "fragment"]:
        if not shader_pass in program:
            continue

        extension = ""
        match shader_pass:
            case "compute":
                extension = ".csh"
            case "vertex":
                extension = ".vsh"
            case "fragment":
                extension = ".fsh"

        with open(f"./shaders/{dimension['folder']}/{program_name}{extension}", "w+") as target_pass:
            target_pass.write(f"#version {json_data['version']}\n")
            with open(f"./{json_data['global_header']}", "r") as header:
                target_pass.writelines(header.readlines())

            target_pass.write(f"#define {dimension['define']}\n")

            if "defines" in program:
                for define, val in program["defines"].items():
                    target_pass.write(f"#define {define} {val}\n")

            with open(f"./shaders/{program[shader_pass]}", "r") as source_pass:
                target_pass.writelines(source_pass.readlines())


for dimension in json_data["dimensions"]:
    # delete the folder for simplicity
    try:
        rmtree(f"./shaders/{dimension['folder']}")
    except Exception:
        pass

    # ...and then make it again
    makedirs(f"./shaders/{dimension['folder']}")

    for stage in ["setup", "begin", "prepare", "deferred", "composite"]:
        if not stage in json_data["passes"]:
            continue
        for i, program in enumerate(json_data["passes"][stage]):
            build_indexed_program(program, i, stage, dimension)

    for render_type, program in json_data["passes"]["gbuffers"].items():
        build_named_program(program, f"gbuffers_{render_type}", dimension)

    for named_program in ["shadow", "final"]:
        if named_program in json_data["passes"]:
            build_named_program(json_data["passes"][named_program], named_program, dimension)
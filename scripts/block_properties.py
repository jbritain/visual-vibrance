from block_wrangler.block_wrangler import *
from pathlib import Path


from caseconverter import pascalcase


shaderpack_root = Path(__file__).parent

def main():
	tags = load_tags()

	Bool = Flag.Config(function_name=lambda flag: f"materialIs{pascalcase(flag)}")
	Sequence = FlagSequence.Config(function_name=lambda flag: f"materialGet{pascalcase(flag)}")
	Enum = EnumFlag.Config(function_name=lambda flag: f"material{pascalcase(flag)}Type") | Sequence
	Int = IntFlag.Config() | Sequence

	mapping = BlockMapping.solve({
		'water': Bool(blocks('minecraft:water')),
		'ice': Bool(blocks('minecraft:ice')),
		'lava': Bool(blocks('minecraft:lava')),
		'plant': Bool(tags['plant']),
		'sway': Enum({
			'upper': tags['sway/upper'],
			'lower': tags['sway/lower'],
			'hanging': tags['sway/hanging'],
			'floating': tags['sway/floating'],
			'full': tags['sway/full']
		}),

		'fire_light_color': Bool(blocks('minecraft:fire', 'minecraft:campfire', 'minecraft:jack_o_lantern')),
		'torch_light_color': Bool(blocks('minecraft:torch', 'minecraft:wall_torch', 'minecraft:lantern')),
		'soul_fire_light_color': Bool(blocks('minecraft:soul_torch', 'minecraft:soul_wall_torch', 'minecraft:soul_fire', 'minecraft:soul_campfire', 'minecraft:soul_lantern'))
	},
	MappingConfig(
		start_index=1001,
		pragma="MATERIAL_IDS_GLSL"
	)

  )

	with shaderpack_root.joinpath('../shaders/block.properties').open('w') as f:
		f.write(mapping.render_encoder())
	with shaderpack_root.joinpath('../shaders/lib/common/materialIDs.glsl').open('w') as f:
		f.write(mapping.render_decoder())

if __name__ == '__main__':
	main()
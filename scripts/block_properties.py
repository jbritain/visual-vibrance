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
		'leaves': Bool(tags['minecraft:leaves']),
		'sway': Enum({
			'upper': tags['sway/upper'],
			'lower': tags['sway/lower'],
			'hanging': tags['sway/hanging'],
			'floating': tags['sway/floating'],
			'full': tags['sway/full']
		}),
		'tinted_glass': Bool(blocks('minecraft:tinted_glass')),

		'fire_light_color': Bool(blocks('minecraft:fire', 'minecraft:campfire', 'minecraft:jack_o_lantern', 'minecraft:lava')),
		'torch_light_color': Bool(blocks('minecraft:torch', 'minecraft:wall_torch', 'minecraft:lantern')),
		'soul_fire_light_color': Bool(blocks('minecraft:soul_torch', 'minecraft:soul_wall_torch', 'minecraft:soul_fire', 'minecraft:soul_campfire', 'minecraft:soul_lantern')),
		'redstone_light_color': Bool(blocks('minecraft:redstone_wire', 'minecraft:redstone_torch', 'minecraft:redstone_wall_torch')),

		'purple_froglight': Bool(blocks('minecraft:pearlescent_froglight')),
		'yellow_froglight': Bool(blocks('minecraft:ochre_froglight')),
		'green_froglight': Bool(blocks('minecraft:verdant_froglight')),

		'lets_light_through': Bool(blocks('minecraft:barrier', 'minecraft:beacon', 'minecraft:azalea', 'minecraft:flowering_azalea', 'minecraft:bamboo', 'minecraft:bell', 'minecraft:sculk_sensor', 'minecraft:calibrated_sculk_sensor', 'minecraft:campfire', 'minecraft:soul_campfire', 'minecraft:cauldron', 'minecraft:chest', 'minecraft:chorus_flower', 'minecraft:chorus_plant', 'minecraft:conduit', 'minecraft:daylight_detector', 'minecraft:decorated_pot', 'minecraft:dirt_path', 'minecraft:dragon_egg', 'minecraft:enchanting_table', 'minecraft:end_portal_frame', 'minecraft:end_rod', 'minecraft:ender_chest', 'minecraft:farmland', 'minecraft:flower_pot', 'minecraft:grindstone', 'minecraft:hopper', 'minecraft:iron_bars', 'minecraft:ladder', 'minecraft:lectern', 'minecraft:lightning_rod', 'minecraft:lily_pad', 'minecraft:moss_carpet', 'minecraft:piston:extended=true', 'minecraft:piston_head', 'minecraft:sticky_piston:extended=true', 'minecraft:snow', 'minecraft:stonecutter', 'minecraft:trapped_chest') + tags['minecraft:anvil'] + tags['minecraft:wool_carpets'] + tags['minecraft:doors'] + tags['minecraft:fence_gates'] + tags['minecraft:fences'] + tags['minecraft:trapdoors'] + tags['minecraft:stairs'])
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
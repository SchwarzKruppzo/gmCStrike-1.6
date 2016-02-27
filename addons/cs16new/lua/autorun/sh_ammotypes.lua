CS16_Penetration_Info = {}
CS16_Bullet_Mat_Info = {}

CS16_Penetration_Info["CS16_357SIG"] = { power = 25, distance = 800 }
CS16_Penetration_Info["CS16_57MM"] = { power = 30, distance = 2000 }
CS16_Penetration_Info["CS16_50AE"] = { power = 30, distance = 1000 }
CS16_Penetration_Info["CS16_9MM"] = { power = 21, distance = 800 }
CS16_Penetration_Info["CS16_338MAGNUM"] = { power = 45, distance = 8000 }
CS16_Penetration_Info["CS16_556NATO"] = { power = 35, distance = 4000 }
CS16_Penetration_Info["CS16_556NATOBOX"] = { power = 35, distance = 4000 }
CS16_Penetration_Info["CS16_762NATO"] = { power = 39, distance = 5000 }
CS16_Penetration_Info["CS16_45ACP"] = { power = 15, distance = 500 }

CS16_Bullet_Mat_Info[MAT_METAL] = { metal = true, power = 0.15, damageMul = 0.2 }
CS16_Bullet_Mat_Info[MAT_CONCRETE] = { power = 0.25 }
CS16_Bullet_Mat_Info[MAT_GRATE] = { metal = true, power = 0.5, damageMul = 0.4 }
CS16_Bullet_Mat_Info[MAT_VENT] = { metal = true, power = 0.5, damageMul = 0.45 }
CS16_Bullet_Mat_Info[MAT_TILE] = { metal = true, power = 0.4, damageMul = 0.45 }
CS16_Bullet_Mat_Info[MAT_COMPUTER] = { power = 0.65, damageMul = 0.3 }
CS16_Bullet_Mat_Info[MAT_WOOD] = { damageMul = 0.6 }

game.AddAmmoType( {
	name = "CS16_BUCKSHOT",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 32,
	minsplash = 2,
	maxsplash = 6
} )

game.AddAmmoType( {
	name = "CS16_9MM",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 120,
	minsplash = 3,
	maxsplash = 8
} )

game.AddAmmoType( {
	name = "CS16_556NATO",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 90,
	minsplash = 8,
	maxsplash = 10
} )

game.AddAmmoType( {
	name = "CS16_556NATOBOX",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 200,
	minsplash = 8,
	maxsplash = 10
} )

game.AddAmmoType( {
	name = "CS16_762NATO",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 90,
	minsplash = 8,
	maxsplash = 10
} )

game.AddAmmoType( {
	name = "CS16_45ACP",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 100,
	minsplash = 3,
	maxsplash = 8
} )

game.AddAmmoType( {
	name = "CS16_50AE",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 35,
	minsplash = 3,
	maxsplash = 8
} )

game.AddAmmoType( {
	name = "CS16_338MAGNUM",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 30,
	minsplash = 8,
	maxsplash = 13
} )

game.AddAmmoType( {
	name = "CS16_57MM",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 100,
	minsplash = 3,
	maxsplash = 8
} )

game.AddAmmoType( {
	name = "CS16_357SIG",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 52,
	minsplash = 3,
	maxsplash = 6
} )

game.AddAmmoType( {
	name = "CS16_HEGRENADE",
	dmgtype = DMG_EXPLOSION,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 30,
	minsplash = 8,
	maxsplash = 13
} )

game.AddAmmoType( {
	name = "CS16_C4",
	dmgtype = DMG_EXPLOSION,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1,
	maxcarry = 30,
	minsplash = 8,
	maxsplash = 13
} )
game.BuildAmmoTypes()
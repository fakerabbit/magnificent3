// ---------------------------------------
// Sprite definitions for 'Sprites'
// Generated with TexturePacker 3.9.2
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class sprites {

    // sprite names
    let BOOTS              = "boots"
    let BOOTS_HIGHLIGHTED  = "boots-highlighted"
    let CACTUS             = "cactus"
    let CACTUS_HIGHLIGHTED = "cactus-highlighted"
    let HAT                = "hat"
    let HAT_HIGHLIGHTED    = "hat-highlighted"
    let PISTOL             = "pistol"
    let PISTOL_HIGHLIGHTED = "pistol-highlighted"
    let SHOE               = "shoe"
    let SHOE_HIGHLIGHTED   = "shoe-highlighted"
    let STAR               = "star"
    let STAR_HIGHLIGHTED   = "star-highlighted"
    let TILE               = "tile"


    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "Sprites")


    // individual texture objects
    func boots() -> SKTexture              { return textureAtlas.textureNamed(BOOTS) }
    func boots_highlighted() -> SKTexture  { return textureAtlas.textureNamed(BOOTS_HIGHLIGHTED) }
    func cactus() -> SKTexture             { return textureAtlas.textureNamed(CACTUS) }
    func cactus_highlighted() -> SKTexture { return textureAtlas.textureNamed(CACTUS_HIGHLIGHTED) }
    func hat() -> SKTexture                { return textureAtlas.textureNamed(HAT) }
    func hat_highlighted() -> SKTexture    { return textureAtlas.textureNamed(HAT_HIGHLIGHTED) }
    func pistol() -> SKTexture             { return textureAtlas.textureNamed(PISTOL) }
    func pistol_highlighted() -> SKTexture { return textureAtlas.textureNamed(PISTOL_HIGHLIGHTED) }
    func shoe() -> SKTexture               { return textureAtlas.textureNamed(SHOE) }
    func shoe_highlighted() -> SKTexture   { return textureAtlas.textureNamed(SHOE_HIGHLIGHTED) }
    func star() -> SKTexture               { return textureAtlas.textureNamed(STAR) }
    func star_highlighted() -> SKTexture   { return textureAtlas.textureNamed(STAR_HIGHLIGHTED) }
    func tile() -> SKTexture               { return textureAtlas.textureNamed(TILE) }

}

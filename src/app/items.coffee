items =
  weapon: [
    {type: 'weapon', index: 0, text: "Sword 1", classes: "weapon_0", notes:'Training weapon.', value:0}
    {type: 'weapon', index: 1, text: "Sword 2", classes:'weapon_1', notes:'Increases experience gain by 3%.', value:20}
    {type: 'weapon', index: 2, text: "Axe", classes:'weapon_2', notes:'Increases experience gain by 6%.', value:30}
    {type: 'weapon', index: 3, text: "Morningstar", classes:'weapon_3', notes:'Increases experience gain by 9%.', value:45}
    {type: 'weapon', index: 4, text: "Blue Sword", classes:'weapon_4', notes:'Increases experience gain by 12%.', value:65}
    {type: 'weapon', index: 5, text: "Red Sword", classes:'weapon_5', notes:'Increases experience gain by 15%.', value:90}
    {type: 'weapon', index: 6, text: "Golden Sword", classes:'weapon_6', notes:'Increases experience gain by 18%.', value:120}
  ]
  armor: [
    {type: 'armor', index: 0, text: "Cloth Armor", classes: 'armor_0', notes:'Training armor.', value:0}
    {type: 'armor', index: 1, text: "Leather Armor", classes: 'armor_1', notes:'Decreases HP loss by 3%.', value:30}
    {type: 'armor', index: 2, text: "Chain Mail", classes: 'armor_2', notes:'Decreases HP loss by 6%.', value:45}
    {type: 'armor', index: 3, text: "Plate Mail", classes: 'armor_3', notes:'Decreases HP loss by 9%.', value:65}
    {type: 'armor', index: 4, text: "Red Armor", classes: 'armor_4', notes:'Decreases HP loss by 12%.', value:90}
    {type: 'armor', index: 5, text: "Golden Armor", classes: 'armor_5', notes:'Decreases HP loss by 15%.', value:120}
  ]
  head: [
    {type: 'head', index: 0, text: "No Helm", classes: 'head_0', notes:'Training armor.', value:0}
    {type: 'head', index: 1, text: "Leather Helm", classes: 'head_1', notes:'Decreases HP loss by 3%.', value:30}
    {type: 'head', index: 2, text: "Chain Coif", classes: 'head_2', notes:'Decreases HP loss by 6%.', value:45}
    {type: 'head', index: 3, text: "Plate Helm", classes: 'head_3', notes:'Decreases HP loss by 9%.', value:65}
    {type: 'head', index: 4, text: "Red Helm", classes: 'head_4', notes:'Decreases HP loss by 12%.', value:90}
    {type: 'head', index: 5, text: "Golden Helm", classes: 'head_5', notes:'Decreases HP loss by 15%.', value:120}
  ]
  shield: [
    {type: 'shield', index: 0, text: "Shield 1", classes: 'shield_0', notes:'Training armor.', value:0}
    {type: 'shield', index: 1, text: "Shield 2", classes: 'shield_1', notes:'Decreases HP loss by 3%.', value:30}
    {type: 'shield', index: 2, text: "Shield 3", classes: 'shield_2', notes:'Decreases HP loss by 6%.', value:45}
    {type: 'shield', index: 3, text: "Shield 4", classes: 'shield_3', notes:'Decreases HP loss by 9%.', value:65}
    {type: 'shield', index: 4, text: "Shielf 5", classes: 'shield_4', notes:'Decreases HP loss by 12%.', value:90}
  ]
  potion: {type: 'potion', text: "Potion", notes: "Recover 15 HP", value: 25, icon: 'item-flask.png'}
  reroll:
    type: 'reroll'
    text: "Re-Roll"
    icon: 'favicon.png'
    notes: "Resets your tasks. When you're struggling and everything's red, use for a clean slate."
    value:0

###
  view exports
###
module.exports.view = (view) ->
  view.fn 'equipped', (user, type) ->
    {gender, armorSet} = user?.preferences || {'m', 'v1'}

    if type=='armor'
      armor = user?.items?.armor || 0
      if gender == 'f'
        return if (parseInt(armor) == 0) then "f_armor_#{armor}_#{armorSet}" else "f_armor_#{armor}"
      else
        return "m_armor_#{armor}"

    else if type=='head'
      head = user?.items?.head || 0
      if gender == 'f'
        return if (parseInt(head) > 1) then "f_head_#{head}_#{armorSet}" else "f_head_#{head}"
      else
        return "m_head_#{head}"

###
  server exports
###
module.exports.server = (model) ->
  updateStore(model)

###
  app exports
###
module.exports.app = (appExports, model) ->
  user = model.at '_user'

  appExports.buyItem = (e, el, next) ->
    user = model.at '_user'
    #TODO: this should be working but it's not. so instead, i'm passing all needed values as data-attrs
    # item = model.at(e.target)

    gp = user.get 'stats.gp'
    [type, value, index] = [ $(el).attr('data-type'), $(el).attr('data-value'), $(el).attr('data-index') ]

    return if gp < value
    user.set 'stats.gp', gp - value
    if type == 'weapon'
      user.set 'items.weapon', index
      updateStore model
    else if type == 'armor'
      user.set 'items.armor', index
      updateStore model
    else if type == 'head'
      user.set 'items.head', index
      updateStore model
    else if type == 'shield'
      user.set 'items.shield', index
      updateStore model
    else if type == 'potion'
      hp = user.get 'stats.hp'
      hp += 15
      hp = 50 if hp > 50
      user.set 'stats.hp', hp

  user.on 'set', 'flags.itemsEnabled', (captures, args) ->
    return unless captures == true
    console.log "IH"
    html = """
           <div class='item-store-popover'>
           <img src='/img/BrowserQuest/chest.png' />
           Congratulations, you have unlocked the Item Store! You can now buy weapons, armor, potions, etc. Read each item's comment for more information.
           <a href='#' onClick="$('ul.items').popover('hide');return false;">[Close]</a>
           </div>
           """
    $('ul.items').popover
      title: "Item Store Unlocked"
      placement: 'left'
      trigger: 'manual'
      html: true
      content: html
    $('ul.items').popover 'show'

###
  update store
###
module.exports.updateStore = updateStore = (model) ->
  obj = model.get('_user')

  i = parseInt(obj?.items?.armor || 0) + 1
  nextArmor = items.armor[i]
  nextArmor.classes = obj.preferences.gender + "_armor_#{i}"

  i = parseInt(parseInt(obj?.items?.head || 0) + 1)
  nextHead = items.head[i]
  nextHead.classes = obj.preferences.gender + "_head_#{i}"
  nextHead.classes += "_#{obj.preferences.armorSet}" if obj.preferences.gender == 'f'

  nextShield = items.shield[parseInt(obj?.items?.shield || 0) + 1]
  nextShield.classes = obj.preferences.gender + "_" + nextShield.classes

  model.set '_view.items',
    weapon: items.weapon[parseInt(obj.items.weapon) + 1]
    armor: nextArmor
    head: nextHead
    shield: nextShield
    potion: items.potion
    reroll: items.reroll




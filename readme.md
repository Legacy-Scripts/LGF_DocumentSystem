# LGF Document System

The LGF Document System is a custom document management system designed for FiveM. It allows players to manage, issue, and view various types of licenses, such as ID cards, driving licenses, weapon licenses, and boat licenses. This system integrates with `ox_inventory` and provides job-specific access to certain documents.

![Example Docs](https://cdn.discordapp.com/attachments/1281031363985936488/1288264556124307516/1_transparent_Craiyon.png?ex=66f48d5c&is=66f33bdc&hm=cb47b42daccd853ca67d99c5cc4057ec15b5e42e80c50c103aee90cf324283ed)

## Features

- **Multiple Document Types**: Supports various licenses, including:
  - ID Cards
  - Driving Licenses
  - Weapon Licenses
  - Boat Licenses
- **Job Restrictions**: Certain documents are only accessible for creation by specific jobs (e.g., only police can create weapon licenses).
- **Dynamic Zones**: Create specific zones on the map where players can interact with NPCs to view or manage documents.
- **Customizable**: Easily add more document types and configure their settings. You can create custom documents by following the structure of existing types in `Config.lua`.
- **Job-Specific Context**: There is a dedicated context for jobs that are allowed to create documents for other players.

## Dependency

- `ox_inventory`
- `screenshot-basic` or `MugShotBase64`

## Framework Supported

- `ESX`
- `QBOX`
- `LegacyCore`

## Installation

1. **Clone the Resource**  
   Add this resource to your `resources` directory in your FiveM server.

2. **Add Items to ox_inventory**  
   To add the documents as items that can be managed by players, modify the `items.lua` file in the `ox_inventory/data/items.lua` directory as follows:

   ```lua
   return {
       ['license_id'] = {
           label = 'ID Card',
           weight = 100,
           consume = 0,
           description = 'Your Personal Document',
           client = {
               export = 'LGF_DocumentSystem.manageDocument'
           }
       },
       ['license_car'] = {
           label = 'Drive Card',
           weight = 150,
           consume = 0,
           description = 'Your Driving License',
           client = {
               export = 'LGF_DocumentSystem.manageDocument'
           }
       },
       ['license_weapon'] = {
           label = 'Weapon License',
           weight = 200,
           consume = 0,
           description = 'License to Carry Weapons',
           client = {
               export = 'LGF_DocumentSystem.manageDocument'
           }
       },
       ['license_boat'] = {
           label = 'License Boat',
           weight = 120,
           consume = 0,
           description = 'License to Operate Boats',
           client = {
               export = 'LGF_DocumentSystem.manageDocument'
           }
       },
   }


   ```

3. **Configure Documents and Zone in `Config.lua`**
   Add your document types in the Config.lua file.

4. **Add your Language `server.cfg`**
   Ensure Language Files are Present: Make sure you have the necessary localization files. You should have a file named %s.json in the locales directory of your LGF_DocumentSystem.

```cfg
setr LGF_DocumentSystem:GetLocales "it"
```

## Exports (server)

### Get All Cards

- Returns all ID cards saved in the `id_card.json` file.

```lua
---@param any
---@return Table
exports.LGF_DocumentSystem:GetAllCards()
```

### Create Document

- Creates a document for a player by `document type`. The docType must match the existing types in the `configuration`, and `playerId` refers to the target player's ID.

```lua
---@param docType string
---@param playerId number
---@return boolean | string
exports.LGF_DocumentSystem:CreateDocument(docType, playerId)
```

#### Example Usage

```lua
lib.addCommand('createdocument', {
    help = 'Creates a document for a specified player',
    params = {
        {
            name = 'playerId',
            type = 'playerId',
            help = 'Target player\'s server ID',
        },
        {
            name = 'docType',
            type = 'string',
            help = 'Type of document to create (must match existing types)',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local playerId = args.playerId
    local docType = args.docType

    local success, result = exports.LGF_DocumentSystem:CreateDocument(docType, playerId)

    if success then
        print(("Document of type '%s' created for player ID %d successfully!"):format( docType, playerId))
    else
        print(("Failed to create document for player ID %d: %s"):format(playerId, result))
    end
end)

```

## Exports (client)

### Has Document of Type

- Check the player inventory to see if she already has that `type of license`.

```lua
---@param docType string
---@return boolean
exports.LGF_DocumentSystem:HasDocumentOfType(docType)
```

### Get State Ui

- Check the `state` of the UI, return true if is opened otherwise false.

```lua
---@return boolean
exports.LGF_DocumentSystem:GetStateDocumentUI()
```

### Open Document

- Open documents by passing `parameters as you like`, Useful for creating fake documents etc.
- Note, You have to create the logic `yourself` for this to be able to show the documents to others etc

```lua
---@param state boolean
---@param data string[]
exports.LGF_DocumentSystem:OpenDocument(state,data)
```

| Key        | Type   | Description                                                                |
| ---------- | ------ | -------------------------------------------------------------------------- |
| Name       | string | The first name of the individual.                                          |
| Surname    | string | The last name of the individual.                                           |
| Sex        | string | The gender of the individual (e.g., "Male", "Female").                     |
| Dob        | string | The date of birth in the format "DD/MM/YYYY".                              |
| Avatar     | string | The Base64 or a url image representation of the individual's avatar image. |
| IdCard     | string | A unique identifier for the document (e.g., "#A0A0A0").                    |
| Expiration | string | The expiration date of the document in the format "DD/MM/YYYY".            |
| TypeDocs   | string | The type of document (e.g., "license_id"), require matching whit existing. |
| Released   | string | The release date of the document in the format "DD/MM/YYYY HH:MM".         |

#### Example Usage

```lua
local keybind = lib.addKeybind({
    name = 'dwadwada',
    description = 'press k To Toggle Document',
    defaultKey = 'K',
    onPressed = function(self)
    -- Check if the Document is already opened
        local isOpened = exports.LGF_DocumentSystem:GetStateDocumentUI()
        if isOpened then
        -- If is opened close the document
            exports.LGF_DocumentSystem:OpenDocument(false, {})
        else
        -- Retrieve the mugshot whit  MugShotBase64 and use it
            local Mugshot = exports["MugShotBase64"]:GetMugShotBase64(cache.ped, true)
            exports.LGF_DocumentSystem:OpenDocument(true, {
                Name = "Entino",
                Surname = "Calogero",
                Sex = "Male",
                Dob = "02/12/1998",
                Avatar = Mugshot,
                IdCard = ("#%s"):format(lib.string.random("A0A0A0", 6)),
                Expiration = "02/01/2026",
                TypeDocs = "license_id",
                Released = "25/09/2021 21:06",
            })
        end
    end,
})
```

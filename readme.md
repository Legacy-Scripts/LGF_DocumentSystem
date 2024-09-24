# LGF Document System

The LGF Document System is a custom document management system designed for FiveM. It allows players to manage, issue, and view various types of licenses, such as ID cards, driving licenses, weapon licenses, and boat licenses. This system integrates with `ox_inventory` and provides job-specific access to certain documents.

---

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

---

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

## Exports

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

![Untamed Raids](https://i.imgur.com/M4EZdTL.png)

# Untamed Garage

Untamed Garage is a script that allows players to manage wagons in the game. Players with specific job roles can access different garage locations to buy, retrieve, and park wagons. The wagons' state and location are tracked in a database, ensuring proper management and availability.

## Features

- **Buy Wagons**: Players can purchase various types of wagons through an in-game menu.
- **Retrieve Wagons**: Retrieve stored wagons from the garage.
- **Park Wagons**: Return wagons to the garage, updating the database.
- **Job-Based Access**: Only players with specific job roles can interact with the garages.
- **Multiple Garage Locations**: Set up multiple garages for different job roles with configurable locations.

## Installation

1. **Download and Extract**: Download the script and extract it into your resources folder.
2. **Rename the Folder**: Ensure the folder is named `untamed_garage`.
3. **Add to Server Config**: Add `ensure untamed_garage` to your `resources.cfg`.
4. **Database Setup**: Import the provided SQL schema to your database.
5. **Configuration**: Customize the script by editing the `config.lua` file to fit your server's needs.

## Configuration

Edit the `config.lua` file to configure garage locations, wagon types, prices, job roles, and prompts.

## Usage

### Buying a Wagon

Players with the appropriate job role can approach a garage location and press the configured prompt key to open the garage menu. They can choose a wagon to buy, and it will spawn at the designated location.

### Retrieving a Wagon

Players can retrieve stored wagons by selecting the retrieve option from the garage menu. They can choose which wagon to retrieve based on availability.

### Parking a Wagon

Players can return a wagon to the garage by approaching the designated parking location and pressing the prompt key. The wagon will be deleted, and the database will be updated to mark the wagon as available.

## Contributing

If you wish to contribute to this project, feel free to fork the repository and make modifications. Pull requests are welcome!

## License

This project is licensed under the GNU General Public License. See the LICENSE file for details.

### SQL Schema

```sql
CREATE TABLE IF NOT EXISTS `UntamedGarage` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `charidentifier` VARCHAR(50) NOT NULL,
    `wagon` VARCHAR(50) NOT NULL,
    `job` VARCHAR(50) NOT NULL,
    `is_taken` BOOLEAN NOT NULL DEFAULT FALSE,
    `last_used` BIGINT NOT NULL,
    PRIMARY KEY (`id`)
);
```


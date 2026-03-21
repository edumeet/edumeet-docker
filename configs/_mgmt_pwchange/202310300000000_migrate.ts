import { Knex } from 'knex';
import bcrypt from 'bcryptjs';
import 'dotenv/config';

export async function up(knex: Knex): Promise<void> {
    await knex('users').where('id', '=', 1).update({
	email: 'admin@breezeshot.com',
	password: bcrypt.hashSync('KhFsKCoDww0vh', 10)
    });
}
export async function down(knex: Knex): Promise<void> {

}
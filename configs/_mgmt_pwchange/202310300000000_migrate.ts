import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

export async function up(knex: Knex): Promise<void> {
    await knex('users').where('id', '=', 1).update({
	email: 'edumeet-admin@localhost',
	password: bcrypt.hashSync('supersecret2', 10)
    });
}
export async function down(knex: Knex): Promise<void> {

}
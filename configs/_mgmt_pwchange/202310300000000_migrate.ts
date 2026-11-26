import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

// Runs once, when the database is created: gives the first user (the super admin) the address
// and the password of MANAGEMENT_USERNAME and MANAGEMENT_PASSWORD in .env. Both are read from
// the environment of the container, so this file holds no secret and is never edited. To change
// the password later, see "Admin password" in docs/operations.md.
export async function up(knex: Knex): Promise<void> {
	const email = process.env.MANAGEMENT_USERNAME;
	const password = process.env.MANAGEMENT_PASSWORD;

	if (!email || !password) return;

	await knex('users').where('id', '=', 1).update({ email, password: bcrypt.hashSync(password, 10) });
}

export async function down(): Promise<void> {
	// Nothing to undo.
}

# Data Directory

This directory is used for Docker volume mounting to persist the SQLite database between container restarts.

## Local Development

When running with Docker Compose, the database file will be stored here:
- `Pcm734Database.db`
- `Pcm734Database.db-shm`
- `Pcm734Database.db-wal`

## Important Notes

⚠️ This directory is in `.gitignore` to prevent committing database files to Git.

⚠️ On Render deployment, this directory is NOT used because containers are ephemeral. Database will be reset on each deploy.

## Production Database

For production with persistent data, consider:
1. Using Render's PostgreSQL database (free tier available)
2. Using external database service (e.g., Supabase, PlanetScale)
3. Implementing database backup/restore mechanism

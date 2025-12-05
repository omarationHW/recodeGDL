<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DeployStoredProcedure extends Command
{
    protected $signature = 'sp:deploy {name}';
    protected $description = 'Deploy a stored procedure from SQL file';

    public function handle()
    {
        $name = $this->argument('name');
        $sqlFile = base_path("../Base/multas_reglamentos/database/generated/{$name}.sql");

        if (!file_exists($sqlFile)) {
            $this->error("SQL file not found: {$sqlFile}");
            return 1;
        }

        $this->info("Deploying {$name}...\n");

        try {
            // Read SQL file
            $sql = file_get_contents($sqlFile);

            // Drop existing function first
            $this->info("1. Dropping old function...");
            DB::statement("DROP FUNCTION IF EXISTS multas_reglamentos.{$name}(VARCHAR) CASCADE");
            $this->info("   ✓ Dropped\n");

            // Create new function
            $this->info("2. Creating new function...");
            DB::unprepared($sql);
            $this->info("   ✓ Created\n");

            // Test the function
            $this->info("3. Testing function...");
            $result = DB::select("SELECT * FROM multas_reglamentos.{$name}(NULL) LIMIT 1");
            $this->info("   ✓ Test successful - Found " . count($result) . " record(s)\n");

            $this->info("✓✓✓ SP Deployed successfully! ✓✓✓");
            return 0;

        } catch (\Exception $e) {
            $this->error("Error deploying SP: " . $e->getMessage());
            return 1;
        }
    }
}

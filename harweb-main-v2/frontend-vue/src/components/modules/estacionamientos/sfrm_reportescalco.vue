<template>
  <div class="reportescalco-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes de Calcomanías</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4>Reportes de Calcomanías</h4>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label class="form-label">Periodo de la relación</label>
          <div class="row g-2 align-items-center">
            <div class="col-auto">
              <input type="date" v-model="fecha1" class="form-control" />
            </div>
            <div class="col-auto">
              <span>a</span>
            </div>
            <div class="col-auto">
              <input type="date" v-model="fecha2" class="form-control" />
            </div>
          </div>
        </div>
        <div class="mb-3">
          <button class="btn btn-success me-2" @click="getCalcomaniaReport">
            <i class="bi bi-printer"></i> Imprimir Reporte de Calcomanías Expedidas
          </button>
          <button class="btn btn-secondary" @click="getFoliosReport">
            <i class="bi bi-printer"></i> Imprimir Reporte de Folios Capturados
          </button>
        </div>
        <div v-if="loading" class="alert alert-info">Cargando...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="reportType === 'calcomania' && reportData.length">
          <h5 class="mt-4">Relación de Calcomanías Expedidas</h5>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead class="table-light">
                <tr>
                  <th>Placa</th>
                  <th>No. Calco</th>
                  <th>Inicial</th>
                  <th>Final</th>
                  <th>Turno</th>
                  <th>Propietario</th>
                  <th>Vigencia</th>
                  <th>Operación de Caja</th>
                  <th>Importe Pagado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in reportData" :key="row.num_calco">
                  <td>{{ row.placa }}</td>
                  <td>{{ row.num_calco }}</td>
                  <td>{{ formatDate(row.fecha_inicial) }}</td>
                  <td>{{ formatDate(row.fecha_fin) }}</td>
                  <td>{{ row.turno }}</td>
                  <td>{{ row.nompropietario }}</td>
                  <td>{{ row.vigencia }}</td>
                  <td>{{ row.operacion_caja }}</td>
                  <td>{{ formatCurrency(row.importe_pago) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="mt-2">
            <strong>Total de Calcomanías:</strong> {{ reportData.length }}
          </div>
        </div>
        <div v-if="reportType === 'folios' && reportData.length">
          <h5 class="mt-4">Relación de Multas de Estacionómetros elaboradas por Inspectores durante el día</h5>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead class="table-light">
                <tr>
                  <th>Inspector</th>
                  <th>Folios Hechos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in reportData" :key="row.vigilante">
                  <td>{{ row.inspector }}</td>
                  <td>{{ row.folios }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="mt-2">
            <strong>Total de Folios:</strong> {{ totalFolios }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReporteEscalcoPage',
  data() {
    const today = new Date().toISOString().substr(0, 10);
    return {
      fecha1: today,
      fecha2: today,
      loading: false,
      error: '',
      reportData: [],
      reportType: '',
    };
  },
  computed: {
    totalFolios() {
      if (!this.reportData.length) return 0;
      return this.reportData.reduce((sum, row) => sum + Number(row.folios), 0);
    }
  },
  methods: {
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    async getCalcomaniaReport() {
      this.loading = true;
      this.error = '';
      this.reportType = 'calcomania';
      this.reportData = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'get_calcomania_report',
            params: {
              fecha1: this.fecha1,
              fecha2: this.fecha2
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.reportData = json.eResponse.data;
        } else {
          this.error = json.eResponse.error || 'Error al obtener el reporte.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async getFoliosReport() {
      this.loading = true;
      this.error = '';
      this.reportType = 'folios';
      this.reportData = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'get_folios_report',
            params: {
              fechora: this.fecha1 // Usamos fecha1 como fecha del día
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.reportData = json.eResponse.data;
        } else {
          this.error = json.eResponse.error || 'Error al obtener el reporte.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.reportescalco-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>

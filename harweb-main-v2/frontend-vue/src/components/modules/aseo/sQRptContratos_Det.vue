<template>
  <div class="contratos-det-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padron de Contratos</li>
      </ol>
    </nav>
    <h2 class="text-center">MUNICIPIO DE GUADALAJARA</h2>
    <h4 class="text-center">DIRECCION DE INGRESOS</h4>
    <h5 class="text-center">Padron de Contratos</h5>
    <div class="mb-3">
      <label for="opcion" class="form-label">Clasificación por:</label>
      <select v-model="filters.opcion" id="opcion" class="form-select" @change="updateClasificacion">
        <option v-for="(label, key) in clasificaciones" :key="key" :value="key">{{ label }}</option>
      </select>
      <span class="badge bg-secondary ms-2">{{ clasificacionLabel }}</span>
    </div>
    <div class="row mb-3">
      <div class="col-md-3">
        <label for="vigencia" class="form-label">Vigencia</label>
        <select v-model="filters.vigencia" id="vigencia" class="form-select">
          <option value="T">Todos</option>
          <option value="V">Vigentes</option>
          <option value="C">Cancelados</option>
        </select>
      </div>
      <div class="col-md-3">
        <label for="ofna" class="form-label">Recaudadora</label>
        <input v-model.number="filters.ofna" id="ofna" type="number" class="form-control" placeholder="ID Recaudadora (0 = Todas)">
      </div>
      <div class="col-md-3">
        <label for="num_emp" class="form-label">Num. Empleado</label>
        <input v-model.number="filters.num_emp" id="num_emp" type="number" class="form-control" placeholder="Num. Empleado (opcional)">
      </div>
      <div class="col-md-3 d-flex align-items-end">
        <button class="btn btn-primary w-100" @click="fetchData">Buscar</button>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="!loading && !error">
      <table class="table table-bordered table-sm">
        <thead class="table-light">
          <tr>
            <th>No. Contrato</th>
            <th>Tipo de Aseo</th>
            <th>Recolección</th>
            <th>Cant.</th>
            <th>Domicilio de la Recolección</th>
            <th>Rec.</th>
            <th>Sec</th>
            <th>Zona</th>
            <th>SZona</th>
            <th>Alta</th>
            <th>Fec-Baja</th>
            <th>Vigencia</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in contratos" :key="row.control_contrato">
            <td>{{ row.num_contrato }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.descripcion_1 }}</td>
            <td>{{ row.cantidad_recolec }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.id_rec }}</td>
            <td>{{ row.sector }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.sub_zona }}</td>
            <td>{{ formatDate(row.aso_mes_oblig) }}</td>
            <td>{{ formatDate(row.fecha_hora_baja) }}</td>
            <td>{{ row.vigencia_label }}</td>
          </tr>
        </tbody>
      </table>
      <div class="row mt-3">
        <div class="col-md-4 offset-md-4">
          <div class="card">
            <div class="card-body">
              <div><strong>Total de Contratos:</strong> {{ summary.total_contratos }}</div>
              <div><strong>Contratos Vigentes:</strong> {{ summary.vigentes }}</div>
              <div><strong>Contratos Cancelados:</strong> {{ summary.cancelados }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosDetPage',
  data() {
    return {
      filters: {
        vigencia: 'T',
        ofna: 0,
        opcion: 1,
        num_emp: null
      },
      clasificaciones: {
        1: 'Numero de Control',
        2: 'Numero de Contrato',
        3: 'Tipo de Aseo',
        4: 'Recaudadora',
        5: 'Tipo de Recoleccion',
        6: 'Vigencia',
        7: 'Fecha de Obligacion',
        8: 'Domicilio'
      },
      clasificacionLabel: 'Numero de Control',
      contratos: [],
      summary: {
        total_contratos: 0,
        vigentes: 0,
        cancelados: 0
      },
      loading: false,
      error: ''
    }
  },
  methods: {
    updateClasificacion() {
      this.clasificacionLabel = this.clasificaciones[this.filters.opcion];
    },
    async fetchData() {
      this.loading = true;
      this.error = '';
      try {
        // Fetch detail
        const detailResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'getContratosDet',
              params: this.filters
            }
          })
        });
        const detailJson = await detailResp.json();
        if (!detailJson.eResponse.success) throw new Error(detailJson.eResponse.message);
        // Add Vigencia label
        this.contratos = (detailJson.eResponse.data || []).map(row => ({
          ...row,
          vigencia_label: row.status_vigencia === 'V' ? 'VIGENTE' : (row.status_vigencia === 'C' ? 'CANCELADO' : row.status_vigencia)
        }));
        // Fetch summary
        const summaryResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'getContratosDetSummary',
              params: this.filters
            }
          })
        });
        const summaryJson = await summaryResp.json();
        if (!summaryJson.eResponse.success) throw new Error(summaryJson.eResponse.message);
        if (summaryJson.eResponse.data && summaryJson.eResponse.data.length > 0) {
          this.summary = summaryJson.eResponse.data[0];
        } else {
          this.summary = { total_contratos: 0, vigentes: 0, cancelados: 0 };
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return '';
      return d.toLocaleDateString();
    }
  },
  mounted() {
    this.updateClasificacion();
    this.fetchData();
  }
}
</script>

<style scoped>
.contratos-det-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
.card {
  background: #f8f9fa;
}
</style>

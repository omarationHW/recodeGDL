<template>
  <div class="repsuspendidas-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Licencias Suspendidas</li>
      </ol>
    </nav>
    <h2 class="text-center mb-4">REPORTE DE SUSPENDIDAS</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="year" class="form-label">Año:</label>
              <input type="number" min="1900" max="2100" class="form-control" v-model="form.year" @input="onYearInput" id="year" placeholder="YYYY">
            </div>
            <div class="col-md-5">
              <label class="form-label">Fecha(s):</label>
              <div class="input-group">
                <input type="date" class="form-control" v-model="form.date_from" @change="onDateChange">
                <span class="input-group-text">a</span>
                <input type="date" class="form-control" v-model="form.date_to">
              </div>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label">Tipo de suspensión:</label>
            <div class="row">
              <div class="col-md-12">
                <div class="btn-group" role="group">
                  <button v-for="(label, idx) in suspensionTypes" :key="idx" type="button" class="btn btn-outline-primary" :class="{active: form.tipo_suspension === idx}" @click="form.tipo_suspension = idx">{{ label }}</button>
                </div>
              </div>
            </div>
          </div>
          <div class="text-end">
            <button type="submit" class="btn btn-success" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm"></span>
              Imprimir / Consultar
            </button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="message && !error" class="alert alert-info">{{ message }}</div>
    <div v-if="results.length > 0" class="card">
      <div class="card-header">
        <strong>Resultados ({{ results.length }})</strong>
      </div>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead class="table-light">
            <tr>
              <th>Licencia</th>
              <th>Propietario</th>
              <th>Actividad</th>
              <th>Teléfono</th>
              <th>No. ext.</th>
              <th>Letra ext.</th>
              <th>No. int.</th>
              <th>Letra int.</th>
              <th>Vigencia</th>
              <th>Estado</th>
              <th>F. alta</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in results" :key="row.id_licencia">
              <td>{{ row.licencia }}</td>
              <td>{{ row.propietarionvo }}</td>
              <td>{{ row.actividad }}</td>
              <td>{{ row.telefono_prop }}</td>
              <td>{{ row.numext_ubic }}</td>
              <td>{{ row.letraext_ubic }}</td>
              <td>{{ row.numint_ubic }}</td>
              <td>{{ row.letraint_ubic }}</td>
              <td>{{ row.vigente }}</td>
              <td>{{ estadoBloqueado(row.bloqueado) }}</td>
              <td>{{ formatDate(row.fecha_otorgamiento) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="card-footer text-end">
        <strong>Total de registros: {{ results.length }}</strong>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepSuspendidasPage',
  data() {
    return {
      form: {
        year: new Date().getFullYear(),
        date_from: '',
        date_to: '',
        tipo_suspension: 0
      },
      suspensionTypes: [
        'Todas',
        'Bloqueo',
        'Estado 1',
        'Cabaret',
        'Suspendida',
        'Responsiva'
      ],
      results: [],
      loading: false,
      error: '',
      message: ''
    };
  },
  methods: {
    onDateChange() {
      this.form.year = '';
    },
    onYearInput() {
      this.form.date_from = '';
      this.form.date_to = '';
    },
    async onSubmit() {
      this.error = '';
      this.message = '';
      this.results = [];
      if (!this.form.year && !this.form.date_from && !this.form.date_to) {
        this.error = 'Debes indicar el año o las fechas de las licencias ...';
        return;
      }
      this.loading = true;
      try {
        const eRequest = {
          action: 'licencias2.repsuspendidas_report',
          payload: {
            year: this.form.year || 0,
            date_from: this.form.date_from || null,
            date_to: this.form.date_to || null,
            tipo_suspension: this.form.tipo_suspension
          }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await response.json();
        if (data.status === 'success') {
          this.results = data.eResponse.data.result || [];
          this.message = data.message || '';
        } else {
          this.error = data.message || 'Error desconocido';
        }
      } catch (error) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    estadoBloqueado(val) {
      switch (String(val)) {
        case '0': return 'NO BLOQUEADO';
        case '1': return 'BLOQUEADO';
        case '2': return 'ESTADO 1';
        case '3': return 'CABARET';
        case '4': return 'SUSPENDIDA';
        case '5': return 'RESPONSIVA';
        default: return 'NO DETERMINADO';
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.repsuspendidas-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 0;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>

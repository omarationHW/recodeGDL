<template>
  <div class="comprobantes-page">
    <h1>Comprobantes Utilizados en un Lapso de Tiempo</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Comprobantes</li>
      </ol>
    </nav>
    <form @submit.prevent="onSubmit">
      <div class="row">
        <div class="col-md-4">
          <div class="card mb-3">
            <div class="card-header">Periodo</div>
            <div class="card-body">
              <div class="mb-3">
                <label for="fechaDesde" class="form-label">Desde:</label>
                <input type="date" v-model="form.fecha_desde" id="fechaDesde" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="fechaHasta" class="form-label">Hasta:</label>
                <input type="date" v-model="form.fecha_hasta" id="fechaHasta" class="form-control" required />
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-5">
          <div class="card mb-3">
            <div class="card-header">Filtros</div>
            <div class="card-body">
              <div class="mb-3">
                <input type="checkbox" id="filtrarMovimiento" v-model="form.filtrar_movimiento" @change="onFiltrarMovimiento" />
                <label for="filtrarMovimiento">Filtrar movimiento</label>
                <select v-if="form.filtrar_movimiento" v-model="form.cvemov" class="form-select mt-2">
                  <option v-for="mov in movimientos" :key="mov.cvemov" :value="mov.cvemov">
                    {{ mov.clavemovto }}
                  </option>
                </select>
              </div>
              <div class="mb-3">
                <input type="checkbox" id="filtrarDepartamento" v-model="form.filtrar_departamento" @change="onFiltrarDepartamento" />
                <label for="filtrarDepartamento">Filtrar departamento</label>
                <select v-if="form.filtrar_departamento" v-model="form.cvedepto" class="form-select mt-2">
                  <option v-for="dep in departamentos" :key="dep.cvedepto" :value="dep.cvedepto">
                    {{ dep.nombredepto }}
                  </option>
                </select>
              </div>
              <div class="mb-3">
                <label for="capturista" class="form-label">Capturista:</label>
                <input type="text" v-model="form.capturista" id="capturista" class="form-control" :disabled="form.filtrar_departamento" />
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card mb-3">
            <div class="card-header">Opciones</div>
            <div class="card-body">
              <div class="mb-3">
                <input type="checkbox" id="totalesDia" v-model="form.totales_dia" />
                <label for="totalesDia">Totales x día</label>
              </div>
              <button type="submit" class="btn btn-primary w-100">Consultar</button>
            </div>
          </div>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="resultados.length" class="mt-4">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Año</th>
            <th>Comprobante</th>
            <th>Capturista</th>
            <th>Fecha Captura</th>
            <th>Recaud</th>
            <th>Urbrus</th>
            <th>Cuenta</th>
            <th>Movimiento</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td>{{ row.axocomp || '' }}</td>
            <td>{{ row.nocomp || '' }}</td>
            <td>{{ row.capturista || '' }}</td>
            <td>{{ row.feccap ? formatFecha(row.feccap) : '' }}</td>
            <td>{{ row.recaud || '' }}</td>
            <td>{{ row.urbrus || '' }}</td>
            <td>{{ row.cuenta || row.cuenta_count || '' }}</td>
            <td>{{ row.clavemovto || '' }}</td>
          </tr>
        </tbody>
      </table>
      <div class="alert alert-secondary">
        <strong>Total de comprobantes:</strong> {{ resultados.length }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ComprobantesPage',
  data() {
    return {
      form: {
        fecha_desde: '',
        fecha_hasta: '',
        filtrar_movimiento: false,
        cvemov: null,
        filtrar_departamento: false,
        cvedepto: null,
        capturista: '',
        totales_dia: false
      },
      movimientos: [],
      departamentos: [],
      resultados: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.fetchMovimientos();
    this.fetchDepartamentos();
  },
  methods: {
    fetchMovimientos() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_movimientos' })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) this.movimientos = json.data;
        });
    },
    fetchDepartamentos() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_departamentos' })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) this.departamentos = json.data;
        });
    },
    onFiltrarMovimiento() {
      if (!this.form.filtrar_movimiento) {
        this.form.cvemov = null;
      }
    },
    onFiltrarDepartamento() {
      if (this.form.filtrar_departamento) {
        this.form.capturista = '';
      } else {
        this.form.cvedepto = null;
      }
    },
    onSubmit() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      const action = this.form.totales_dia ? 'get_comprobantes_totales_dia' : 'get_comprobantes_report';
      const params = {
        fecha_desde: this.form.fecha_desde,
        fecha_hasta: this.form.fecha_hasta,
        filtrar_movimiento: this.form.filtrar_movimiento,
        cvemov: this.form.cvemov,
        filtrar_capturista: !!this.form.capturista,
        capturista: this.form.capturista,
        cvedepto: this.form.filtrar_departamento ? this.form.cvedepto : null
      };
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      })
        .then(res => res.json())
        .then(json => {
          this.loading = false;
          if (json.success) {
            this.resultados = json.data;
          } else {
            this.error = json.message || 'Error al consultar.';
          }
        })
        .catch(err => {
          this.loading = false;
          this.error = err.message || 'Error de red.';
        });
    },
    formatFecha(fecha) {
      if (!fecha) return '';
      // Espera formato ISO
      const d = new Date(fecha);
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.comprobantes-page {
  max-width: 1200px;
  margin: 0 auto;
}
.card-header {
  font-weight: bold;
}
</style>

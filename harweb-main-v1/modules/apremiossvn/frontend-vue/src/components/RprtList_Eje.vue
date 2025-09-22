<template>
  <div class="rprtlist-eje-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Requerimientos</li>
      </ol>
    </nav>
    <h2>Listado de Requerimientos (RprtList_Eje)</h2>
    <form @submit.prevent="fetchReport">
      <div class="row">
        <div class="col-md-3">
          <label>Ejecutores (IDs, separados por coma)</label>
          <input v-model="form.varios" class="form-control" placeholder="Ej: 1,2,3" required />
        </div>
        <div class="col-md-2">
          <label>Vigencia</label>
          <select v-model="form.vvig" class="form-control">
            <option value="1">Vigentes</option>
            <option value="2">Pagados</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Zona/Recaudadora</label>
          <input v-model="form.vrec" class="form-control" placeholder="Zona" />
        </div>
        <div class="col-md-2">
          <label>Opción de Fecha</label>
          <select v-model.number="form.vopc" class="form-control">
            <option :value="1">Fecha Practicado</option>
            <option :value="2">Fecha Actualización</option>
            <option :value="3">Fecha Pago y Practicado</option>
            <option :value="4">Fecha Entrega 1</option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Nombre del Ejecutor</label>
          <input v-model="form.vnombre" class="form-control" placeholder="Nombre" />
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-2">
          <label>Fecha Inicial</label>
          <input type="date" v-model="form.vfec1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Fecha Final</label>
          <input type="date" v-model="form.vfec2" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Recaudadora (ID)</label>
          <input v-model.number="form.vrecaudadora" class="form-control" />
        </div>
        <div class="col-md-2" v-if="form.vopc == 3">
          <label>Fecha Practicado Inicial</label>
          <input type="date" v-model="form.vfecP1" class="form-control" />
        </div>
        <div class="col-md-2" v-if="form.vopc == 3">
          <label>Fecha Practicado Final</label>
          <input type="date" v-model="form.vfecP2" class="form-control" />
        </div>
        <div class="col-md-2">
          <label>Solo < 90 días</label>
          <select v-model="form.v90d" class="form-control">
            <option value="S">Sí</option>
            <option value="N">No</option>
          </select>
        </div>
      </div>
      <div class="mt-3">
        <button class="btn btn-primary" type="submit" :disabled="loading">Buscar</button>
      </div>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="results.length" class="mt-4">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm table-striped">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Clave Practicado</th>
            <th>Fecha Practicado</th>
            <th>Ejecutor</th>
            <th>Nombre</th>
            <th>Datos</th>
            <th>Importe Pago</th>
            <th>Gastos Requer.</th>
            <th>Total Certificado</th>
            <th>Días Pasados</th>
            <th>Total Notif.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in results" :key="row.id_control">
            <td>{{ row.folio }}</td>
            <td>{{ row.clave_practicado }}</td>
            <td>{{ row.fecha_practicado }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.datos }}</td>
            <td>{{ row.importe_pago }}</td>
            <td>{{ row.gtos_requer }}</td>
            <td>{{ row.totcer }}</td>
            <td>{{ row.diaspas }}</td>
            <td>{{ row.totalnotif }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ results.length }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtListEjePage',
  data() {
    return {
      form: {
        varios: '',
        vvig: '1',
        vrec: '',
        vopc: 1,
        vfec1: '',
        vfec2: '',
        vrecaudadora: '',
        vfecP1: '',
        vfecP2: '',
        vnombre: '',
        v90d: 'N'
      },
      results: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.results = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            action: 'getRprtListEje',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.success) {
          this.results = data.data;
        } else {
          this.error = data.message || 'Error al obtener datos';
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
.rprtlist-eje-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>

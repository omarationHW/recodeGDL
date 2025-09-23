<template>
  <div class="carga-pag-diversos-page">
    <h1>Carga de Pagos Diversos</h1>
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga Pagos Diversos</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarPagos">
          <div class="row g-3 align-items-end">
            <div class="col-md-3">
              <label for="fechaDesde" class="form-label">Fecha Desde</label>
              <input type="date" v-model="form.fecha_desde" class="form-control" id="fechaDesde" required>
            </div>
            <div class="col-md-3">
              <label for="fechaHasta" class="form-label">Fecha Hasta</label>
              <input type="date" v-model="form.fecha_hasta" class="form-control" id="fechaHasta" required>
            </div>
            <div class="col-md-3">
              <label for="recaudadora" class="form-label">Recaudadora</label>
              <select v-model="form.recaudadora" class="form-select" id="recaudadora" required>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.recaudadora }} ({{ rec.id_rec }})
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="pagos.length > 0" class="card mb-3">
      <div class="card-header">Pagos Diversos Encontrados</div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-sm table-striped mb-0">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Rec.</th>
                <th>Caja</th>
                <th>Operación</th>
                <th>Tipo</th>
                <th>Parc.</th>
                <th>Tot.</th>
                <th>Importe</th>
                <th>Col</th>
                <th>Calle</th>
                <th>Folio</th>
                <th>Seleccionar</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(pago, idx) in pagos" :key="idx">
                <td>{{ pago.fecing }}</td>
                <td>{{ pago.recing }}</td>
                <td>{{ pago.cajing }}</td>
                <td>{{ pago.opcaja }}</td>
                <td>{{ pago.tipo_rbo }}</td>
                <td>{{ pago.mes_desde }}</td>
                <td>{{ pago.axo_desde }}</td>
                <td>{{ pago.pagado.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' }) }}</td>
                <td>{{ pago.colonia }}</td>
                <td>{{ pago.obra }}</td>
                <td>{{ pago.numero }}</td>
                <td>
                  <input type="checkbox" v-model="pago.selected">
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="p-3">
          <button class="btn btn-success" @click="grabarPagos" :disabled="!pagos.some(p => p.selected)">
            Grabar Pagos Seleccionados
          </button>
        </div>
      </div>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Procesando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="success" class="alert alert-success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'CargaPagDiversosPage',
  data() {
    return {
      form: {
        fecha_desde: '',
        fecha_hasta: '',
        recaudadora: ''
      },
      recaudadoras: [],
      pagos: [],
      loading: false,
      error: '',
      success: ''
    }
  },
  mounted() {
    this.fetchRecaudadoras();
    // Default fechas hoy
    const today = new Date().toISOString().slice(0, 10);
    this.form.fecha_desde = today;
    this.form.fecha_hasta = today;
  },
  methods: {
    async fetchRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getRecaudadoras',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
        }
      } catch (error) {
        this.error = 'Error al cargar recaudadoras';
      }
    },
    async buscarPagos() {
      this.error = '';
      this.success = '';
      this.loading = true;
      this.pagos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.buscarPagosDiversos',
          payload: {
            fecha_desde: this.form.fecha_desde,
            fecha_hasta: this.form.fecha_hasta,
            recaudadora: this.form.recaudadora
          }
        });
        if (res.data.status === 'success') {
          this.pagos = res.data.data.map(p => ({ ...p, selected: false }));
        } else {
          this.error = res.data.message || 'Error al buscar pagos';
        }
      } catch (error) {
        this.error = 'Error de red al buscar pagos';
      } finally {
        this.loading = false;
      }
    },
    async grabarPagos() {
      this.error = '';
      this.success = '';
      this.loading = true;
      const pagosSeleccionados = this.pagos.filter(p => p.selected);
      if (pagosSeleccionados.length === 0) {
        this.error = 'Debe seleccionar al menos un pago.';
        this.loading = false;
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.grabarPagosDiversos',
          payload: { pagos: pagosSeleccionados }
        });
        if (res.data.status === 'success') {
          this.success = res.data.message;
          this.buscarPagos();
        } else {
          this.error = res.data.message || 'Error al grabar pagos';
        }
      } catch (error) {
        this.error = 'Error de red al grabar pagos';
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.carga-pag-diversos-page {
  max-width: 1200px;
  margin: 0 auto;
}
</style>

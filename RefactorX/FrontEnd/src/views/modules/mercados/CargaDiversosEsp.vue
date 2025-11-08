<template>
  <div class="carga-diversos-esp">
    <h1>Carga Especial de Pagos Realizados por Diversos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga Diversos Especial</li>
      </ol>
    </nav>
    <div class="form-group row">
      <label class="col-sm-2 col-form-label">Fecha de Pago:</label>
      <div class="col-sm-3">
        <input type="date" v-model="fechaPago" class="form-control" />
      </div>
      <div class="col-sm-2">
        <button class="btn btn-primary" @click="buscarAdeudos">Buscar</button>
      </div>
      <div class="col-sm-2">
        <button class="btn btn-success" :disabled="pagos.length === 0" @click="cargarPagos">Grabar</button>
      </div>
      <div class="col-sm-2">
        <button class="btn btn-secondary" @click="$router.push('/')">Salir</button>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="adeudos.length > 0">
      <table class="table table-bordered table-sm mt-3">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col">{{ col }}</th>
            <th>Partida</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td v-for="col in columns" :key="col">{{ row[col] }}</td>
            <td>
              <input type="text" v-model="pagos[idx].partida" class="form-control form-control-sm" />
            </td>
          </tr>
        </tbody>
      </table>
      <div class="alert alert-info">
        <b>Nota:</b> Solo se grabarán los pagos con número de partida distinto de vacío o cero.
      </div>
    </div>
    <div v-if="successMsg" class="alert alert-success mt-3">{{ successMsg }}</div>
  </div>
</template>

<script>
export default {
  name: 'CargaDiversosEsp',
  data() {
    return {
      fechaPago: '',
      adeudos: [],
      pagos: [],
      columns: [
        'FECHA', 'REC', 'CAJA', 'OPER', 'AÑO', 'MES', 'RENTA', 'OFN', 'MER', 'CAT', 'SEC', 'LOCAL', 'LET'
      ],
      loading: false,
      error: '',
      successMsg: ''
    };
  },
  methods: {
    async buscarAdeudos() {
      this.loading = true;
      this.error = '';
      this.successMsg = '';
      this.adeudos = [];
      this.pagos = [];
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getAdeudos',
            data: { fecha_pago: this.fechaPago }
          }
        });
        if (resp.data.eResponse.success) {
          this.adeudos = resp.data.eResponse.data;
          this.pagos = this.adeudos.map(row => ({ partida: '' }));
        } else {
          this.error = resp.data.eResponse.message || 'Error al buscar adeudos';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async cargarPagos() {
      this.loading = true;
      this.error = '';
      this.successMsg = '';
      // Solo pagos con partida válida
      const pagosValidos = this.adeudos.map((row, idx) => {
        return {
          ...row,
          partida: this.pagos[idx].partida
        };
      }).filter(p => p.partida && p.partida !== '0');
      if (pagosValidos.length === 0) {
        this.error = 'No hay pagos válidos para grabar.';
        this.loading = false;
        return;
      }
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'cargarPagos',
            data: {
              pagos: pagosValidos,
              usuario: this.$store.state.usuario_id || 1,
              fecha_pago: this.fechaPago
            }
          }
        });
        if (resp.data.eResponse.success) {
          this.successMsg = 'Pagos cargados correctamente.';
          this.buscarAdeudos();
        } else {
          this.error = resp.data.eResponse.message || 'Error al grabar pagos';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.carga-diversos-esp {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>

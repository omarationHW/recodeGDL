<template>
  <div class="apremios-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Apremios</li>
      </ol>
    </nav>
    <h1>Apremios</h1>
    <form @submit.prevent>
      <div class="row">
        <div class="col-md-2">
          <label for="zona">Zona</label>
          <input v-model="apremio.zona" id="zona" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="folio">Folio</label>
          <input v-model="apremio.folio" id="folio" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="diligencia">Cve Diligencia</label>
          <input v-model="apremio.diligencia" id="diligencia" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="importe_global">$ Global</label>
          <input v-model="apremio.importe_global" id="importe_global" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="importe_multa">$ Multa</label>
          <input v-model="apremio.importe_multa" id="importe_multa" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="importe_recargo">$ Recargo</label>
          <input v-model="apremio.importe_recargo" id="importe_recargo" class="form-control" disabled />
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-2">
          <label for="importe_gastos">$ Gastos</label>
          <input v-model="apremio.importe_gastos" id="importe_gastos" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="zona_apremio">Zona Apremio</label>
          <input v-model="apremio.zona_apremio" id="zona_apremio" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="fecha_emision">Fecha Emisión</label>
          <input v-model="apremio.fecha_emision" id="fecha_emision" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="clave_practicado">Cve Practicado</label>
          <input v-model="apremio.clave_practicado" id="clave_practicado" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="fecha_practicado">Fecha Practicado</label>
          <input v-model="apremio.fecha_practicado" id="fecha_practicado" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="hora_practicado">Hora Practicado</label>
          <input v-model="apremio.hora_practicado" id="hora_practicado" class="form-control" disabled />
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-2">
          <label for="fecha_entrega1">Fecha Entrega 1</label>
          <input v-model="apremio.fecha_entrega1" id="fecha_entrega1" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="fecha_entrega2">Fecha Entrega 2</label>
          <input v-model="apremio.fecha_entrega2" id="fecha_entrega2" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="fecha_citatorio">Fecha Citatorio</label>
          <input v-model="apremio.fecha_citatorio" id="fecha_citatorio" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="hora">Hora Citatorio</label>
          <input v-model="apremio.hora" id="hora" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="ejecutor">Ejecutor</label>
          <input v-model="apremio.ejecutor" id="ejecutor" class="form-control" disabled />
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-2">
          <label for="clave_secuestro">Cve Secuestro</label>
          <input v-model="apremio.clave_secuestro" id="clave_secuestro" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="clave_remate">Cve Remate</label>
          <input v-model="apremio.clave_remate" id="clave_remate" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="fecha_remate">Fecha Remate</label>
          <input v-model="apremio.fecha_remate" id="fecha_remate" class="form-control" disabled />
        </div>
        <div class="col-md-2">
          <label for="porcentaje_multa">% Multa</label>
          <input v-model="apremio.porcentaje_multa" id="porcentaje_multa" class="form-control" disabled />
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-12">
          <label for="observaciones">Observaciones</label>
          <textarea v-model="apremio.observaciones" id="observaciones" class="form-control" rows="2" disabled></textarea>
        </div>
      </div>
      <div class="row mt-4">
        <div class="col-md-12">
          <h5>Periodos Requeridos</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th>Año</th>
                <th>Periodo</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Cantidad</th>
                <th>Tipo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="periodo in periodos" :key="periodo.ayo + '-' + periodo.periodo">
                <td>{{ periodo.ayo }}</td>
                <td>{{ periodo.periodo }}</td>
                <td>{{ periodo.importe }}</td>
                <td>{{ periodo.recargos }}</td>
                <td>{{ periodo.cantidad }}</td>
                <td>{{ periodo.tipo }}</td>
              </tr>
              <tr v-if="periodos.length === 0">
                <td colspan="6" class="text-center">No hay periodos requeridos.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="row mt-4">
        <div class="col-md-12 text-end">
          <button class="btn btn-secondary" @click="goBack">Salir</button>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'ApremiosPage',
  data() {
    return {
      apremio: {
        zona: '',
        folio: '',
        diligencia: '',
        importe_global: '',
        importe_multa: '',
        importe_recargo: '',
        importe_gastos: '',
        zona_apremio: '',
        fecha_emision: '',
        clave_practicado: '',
        fecha_practicado: '',
        hora_practicado: '',
        fecha_entrega1: '',
        fecha_entrega2: '',
        fecha_citatorio: '',
        hora: '',
        ejecutor: '',
        clave_secuestro: '',
        clave_remate: '',
        fecha_remate: '',
        porcentaje_multa: '',
        observaciones: ''
      },
      periodos: [],
      modulo: null,
      control: null,
      loading: false,
      error: null
    };
  },
  created() {
    // Espera recibir params por query o route
    this.modulo = this.$route.query.modulo || this.$route.params.modulo;
    this.control = this.$route.query.control || this.$route.params.control;
    if (this.modulo && this.control) {
      this.fetchApremios();
    } else {
      this.error = 'Faltan parámetros de módulo o control.';
    }
  },
  methods: {
    async fetchApremios() {
      this.loading = true;
      this.error = null;
      try {
        // Obtener datos de apremios
        const res = await this.$axios.post('/api/execute', {
          action: 'otras-oblig.get_apremios',
          payload: {
            modulo: this.modulo,
            control: this.control
          }
        });
        if (res.data.status === 'success' && res.data.data.length > 0) {
          this.apremio = res.data.data[0];
          this.fetchPeriodos(this.apremio.id_control);
        } else {
          this.error = 'No se encontró información de apremios.';
        }
      } catch (err) {
        this.error = 'Error al obtener apremios: ' + err;
      } finally {
        this.loading = false;
      }
    },
    async fetchPeriodos(id_control) {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'otras-oblig.get_periodos_apremio',
          payload: { id_control }
        });
        if (res.data.status === 'success') {
          this.periodos = res.data.data;
        } else {
          this.periodos = [];
        }
      } catch (err) {
        this.periodos = [];
      }
    },
    goBack() {
      this.$router.back();
    }
  }
};
</script>

<style scoped>
.apremios-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>

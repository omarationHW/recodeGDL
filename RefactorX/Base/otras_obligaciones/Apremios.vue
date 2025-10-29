<template>
  <div class="apremios-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Apremios</li>
      </ol>
    </nav>
    <h2>Apremios</h2>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <div class="row">
          <div class="col-md-2">
            <label>ZONA</label>
            <input v-model="apremio.zona" type="number" class="form-control" required />
          </div>
          <div class="col-md-2">
            <label>FOLIO</label>
            <input v-model="apremio.folio" type="number" class="form-control" required />
          </div>
          <div class="col-md-2">
            <label>Cve Diligencia</label>
            <input v-model="apremio.diligencia" maxlength="1" class="form-control" required />
          </div>
          <div class="col-md-2">
            <label>$ GLOBAL</label>
            <input v-model="apremio.importe_global" type="number" step="0.01" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>$ MULTA</label>
            <input v-model="apremio.importe_multa" type="number" step="0.01" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>$ RECARGO</label>
            <input v-model="apremio.importe_recargo" type="number" step="0.01" class="form-control" />
          </div>
        </div>
        <div class="row mt-2">
          <div class="col-md-2">
            <label>$ GASTOS</label>
            <input v-model="apremio.importe_gastos" type="number" step="0.01" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>ZONA APREMIO</label>
            <input v-model="apremio.zona_apremio" type="number" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>FECHA EMISION</label>
            <input v-model="apremio.fecha_emision" type="date" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>PRACTICADO (Cve)</label>
            <input v-model="apremio.clave_practicado" maxlength="1" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>Fecha Practicado</label>
            <input v-model="apremio.fecha_practicado" type="date" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>Hora Practicado</label>
            <input v-model="apremio.hora_practicado" type="time" class="form-control" />
          </div>
        </div>
        <div class="row mt-2">
          <div class="col-md-2">
            <label>FECHA ENTREGA 1</label>
            <input v-model="apremio.fecha_entrega1" type="date" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>FECHA ENTREGA 2</label>
            <input v-model="apremio.fecha_entrega2" type="date" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>CITATORIO (Fecha)</label>
            <input v-model="apremio.fecha_citatorio" type="date" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>Hora Citatorio</label>
            <input v-model="apremio.hora" type="time" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>EJECUTOR</label>
            <input v-model="apremio.ejecutor" class="form-control" />
          </div>
        </div>
        <div class="row mt-2">
          <div class="col-md-2">
            <label>CVE SECUESTRO</label>
            <input v-model="apremio.clave_secuestro" type="number" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>REMATE (Cve)</label>
            <input v-model="apremio.clave_remate" maxlength="1" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>Fecha Remate</label>
            <input v-model="apremio.fecha_remate" type="date" class="form-control" />
          </div>
          <div class="col-md-2">
            <label>% MULTA</label>
            <input v-model="apremio.porcentaje_multa" type="number" class="form-control" />
          </div>
          <div class="col-md-4">
            <label>Observaciones</label>
            <input v-model="apremio.observaciones" class="form-control" />
          </div>
        </div>
        <div class="mt-3">
          <button type="submit" class="btn btn-primary">Guardar</button>
          <button type="button" class="btn btn-secondary ml-2" @click="onCancel">Salir</button>
        </div>
      </form>
      <div class="mt-4">
        <h4>Periodos Requeridos</h4>
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
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'ApremiosPage',
  data() {
    return {
      loading: true,
      apremio: {
        id_control: null,
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
        observaciones: '',
        modulo: '',
        control_otr: ''
      },
      periodos: [],
      par_modulo: 1, // Puede venir de ruta o props
      par_control: 1 // Puede venir de ruta o props
    };
  },
  created() {
    // Cargar datos iniciales
    this.fetchApremios();
  },
  methods: {
    async fetchApremios() {
      this.loading = true;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'get_apremios',
          params: {
            par_modulo: this.par_modulo,
            par_control: this.par_control
          }
        });
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          this.apremio = { ...this.apremio, ...data.eResponse.data[0] };
          this.apremio.modulo = this.par_modulo;
          this.apremio.control_otr = this.par_control;
          this.apremio.id_control = data.eResponse.data[0].id_control;
          this.fetchPeriodos(this.apremio.id_control);
        } else {
          this.apremio.modulo = this.par_modulo;
          this.apremio.control_otr = this.par_control;
          this.periodos = [];
        }
      } catch (e) {
        alert('Error al cargar apremios: ' + e);
      }
      this.loading = false;
    },
    async fetchPeriodos(id_control) {
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'get_periodos_by_control',
          params: { id_control }
        });
        if (data.eResponse.success) {
          this.periodos = data.eResponse.data;
        } else {
          this.periodos = [];
        }
      } catch (e) {
        this.periodos = [];
      }
    },
    async onSubmit() {
      this.loading = true;
      try {
        let eRequest = this.apremio.id_control ? 'update_apremio' : 'create_apremio';
        const { data } = await axios.post('/api/execute', {
          eRequest,
          params: this.apremio
        });
        if (data.eResponse.success) {
          alert('Guardado correctamente');
          this.fetchApremios();
        } else {
          alert('Error al guardar: ' + data.eResponse.message);
        }
      } catch (e) {
        alert('Error al guardar: ' + e);
      }
      this.loading = false;
    },
    onCancel() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.apremios-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
}
</style>

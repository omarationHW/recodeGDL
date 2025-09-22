<template>
  <div class="datos-convenio-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Datos de Convenio</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header d-flex align-items-center justify-content-between">
        <div>
          <h4 class="mb-0">Convenio <span class="text-primary">{{ convenioLabel }}</span></h4>
        </div>
        <button class="btn btn-outline-secondary" @click="goBack">
          <i class="fa fa-sign-out-alt"></i> Salir
        </button>
      </div>
      <div class="card-body">
        <form v-if="datosGenerales" autocomplete="off">
          <div class="row mb-3">
            <div class="col-md-6 mb-2">
              <label>Nombre</label>
              <input type="text" class="form-control" :value="datosGenerales.nombre" readonly>
            </div>
            <div class="col-md-6 mb-2">
              <label>Calle</label>
              <input type="text" class="form-control" :value="datosGenerales.calle" readonly>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-2 mb-2">
              <label>Ext.</label>
              <input type="text" class="form-control" :value="datosGenerales.num_exterior" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Int.</label>
              <input type="text" class="form-control" :value="datosGenerales.num_interior" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Inciso</label>
              <input type="text" class="form-control" :value="datosGenerales.inciso" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Vigencia</label>
              <input type="text" class="form-control" :value="datosGenerales.vigencia" readonly>
            </div>
            <div class="col-md-4 mb-2">
              <label>Periodos</label>
              <input type="text" class="form-control" :value="datosGenerales.periodos" readonly>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-3 mb-2">
              <label>Fecha Inicio</label>
              <input type="text" class="form-control" :value="formatDate(datosGenerales.fecha_inicio)" readonly>
            </div>
            <div class="col-md-3 mb-2">
              <label>Fecha Venc.</label>
              <input type="text" class="form-control" :value="formatDate(datosGenerales.fecha_venc)" readonly>
            </div>
            <div class="col-md-3 mb-2">
              <label>Tipo Pago</label>
              <input type="text" class="form-control" :value="datosGenerales.tipo_pago" readonly>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-2 mb-2">
              <label>Impuesto</label>
              <input type="text" class="form-control" :value="formatCurrency(datosGenerales.impuesto)" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Recargos</label>
              <input type="text" class="form-control" :value="formatCurrency(datosGenerales.recargos)" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Gastos</label>
              <input type="text" class="form-control" :value="formatCurrency(datosGenerales.gastos)" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Multa</label>
              <input type="text" class="form-control" :value="formatCurrency(datosGenerales.multa)" readonly>
            </div>
            <div class="col-md-2 mb-2">
              <label>Total</label>
              <input type="text" class="form-control" :value="formatCurrency(datosGenerales.total)" readonly>
            </div>
          </div>
        </form>
        <div v-else class="text-center py-5">
          <span class="spinner-border"></span> Cargando datos generales...
        </div>
      </div>
    </div>
    <div class="card">
      <div class="card-header">
        <h5 class="mb-0">Parcialidades</h5>
      </div>
      <div class="card-body p-0">
        <div v-if="parcialidades && parcialidades.length">
          <table class="table table-striped table-bordered mb-0">
            <thead>
              <tr>
                <th>Parcialidad</th>
                <th>Impuesto Adeudo</th>
                <th>Periodos</th>
                <th>Fecha Pago</th>
                <th>Rec. de Pago</th>
                <th>Caja de Pago</th>
                <th>Oper. de Pago</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="parcial in parcialidades" :key="parcial.parcial">
                <td>{{ parcial.parcial }}</td>
                <td>{{ formatCurrency(parcial.impuesto_adeudo) }}</td>
                <td>{{ parcial.periodos }}</td>
                <td>{{ formatDate(parcial.fecha_pago) }}</td>
                <td>{{ parcial.oficina_pago }}</td>
                <td>{{ parcial.caja_pago }}</td>
                <td>{{ parcial.operacion_pago }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="text-center py-5">
          <span class="spinner-border"></span> Cargando parcialidades...
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'DatosConvenioPage',
  props: {
    convenio: {
      type: String,
      required: true
    },
    control: {
      type: [String, Number],
      required: true
    }
  },
  data() {
    return {
      datosGenerales: null,
      parcialidades: null
    };
  },
  computed: {
    convenioLabel() {
      return this.convenio;
    }
  },
  methods: {
    async fetchDatosGenerales() {
      try {
        const res = await axios.post('/api/execute', {
          eRequest: 'getDatosConvenio',
          params: { control: this.control }
        });
        if (res.data.eResponse.success && res.data.eResponse.data.length) {
          this.datosGenerales = res.data.eResponse.data[0];
        }
      } catch (e) {
        this.datosGenerales = null;
      }
    },
    async fetchParcialidades() {
      try {
        const res = await axios.post('/api/execute', {
          eRequest: 'getParcialidadesConvenio',
          params: { control: this.control }
        });
        if (res.data.eResponse.success) {
          this.parcialidades = res.data.eResponse.data;
        }
      } catch (e) {
        this.parcialidades = [];
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    goBack() {
      this.$router.back();
    }
  },
  mounted() {
    this.fetchDatosGenerales();
    this.fetchParcialidades();
  }
};
</script>

<style scoped>
.datos-convenio-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1.5rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>

<template>
  <div class="cons-remesas-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Remesas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header d-flex align-items-center justify-content-between">
        <div>
          <h5 class="mb-0">Consulta de Remesas</h5>
        </div>
        <button class="btn btn-danger" @click="goBack">Salir</button>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label class="form-label">Datos de Remesas Recibidas y Enviadas a SECFIN</label>
          <div class="btn-group" role="group">
            <button
              v-for="(label, idx) in radioOptions"
              :key="idx"
              :class="['btn', 'btn-outline-primary', { active: selectedTipo === tipos[idx] }]"
              @click="onTipoChange(tipos[idx])"
            >
              {{ label }}
            </button>
          </div>
        </div>
        <div class="row">
          <div class="col-md-5">
            <h6>Remesas</h6>
            <table class="table table-sm table-hover table-bordered">
              <thead>
                <tr>
                  <th>Fecha Inicio</th>
                  <th>Fecha Fin</th>
                  <th>Fecha Creación</th>
                  <th>No. Remesa</th>
                  <th>No. Registros</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="remesa in remesas" :key="remesa.num_remesa" @dblclick="onRemesaDblClick(remesa)" style="cursor:pointer">
                  <td>{{ formatDate(remesa.fecha_inicio) }}</td>
                  <td>{{ formatDate(remesa.fecha_fin) }}</td>
                  <td>{{ formatDate(remesa.fecha_hoy) }}</td>
                  <td>{{ remesa.num_remesa }}</td>
                  <td>{{ remesa.cant_reg }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="col-md-7" v-if="remesaDetalleVisible">
            <h6>Detalle de Remesa</h6>
            <table class="table table-sm table-bordered table-striped">
              <thead>
                <tr>
                  <th v-for="col in detalleColumns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in remesaDetalle" :key="idx">
                  <td v-for="col in detalleColumns" :key="col">{{ row[col] }}</td>
                </tr>
              </tbody>
            </table>
            <div v-if="remesaDetalle.length === 0" class="alert alert-warning">No hay detalle para esta remesa.</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'ConsRemesasPage',
  data() {
    return {
      tipos: ['A', 'B', 'C', 'D'],
      radioOptions: [
        'Del Estado',
        'Altas enviadas',
        'Pgos. en Ofnas.',
        'Pgos. en Banorte'
      ],
      selectedTipo: 'A',
      remesas: [],
      remesaDetalle: [],
      remesaDetalleVisible: false,
      detalleColumns: []
    };
  },
  created() {
    this.fetchRemesas();
  },
  methods: {
    goBack() {
      this.$router.back();
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      return new Date(dateStr).toLocaleDateString();
    },
    onTipoChange(tipo) {
      this.selectedTipo = tipo;
      this.remesaDetalleVisible = false;
      this.fetchRemesas();
    },
    fetchRemesas() {
      axios.post('/api/execute', {
        eRequest: 'getRemesas',
        params: { tipo: this.selectedTipo }
      }).then(resp => {
        const data = resp.data.eResponse.data || [];
        this.remesas = data;
      });
    },
    onRemesaDblClick(remesa) {
      axios.post('/api/execute', {
        eRequest: 'getRemesaDetalle',
        params: {
          tipo: this.selectedTipo,
          num_remesa: remesa.num_remesa
        }
      }).then(resp => {
        const data = resp.data.eResponse.data || [];
        this.remesaDetalle = data;
        this.remesaDetalleVisible = data.length > 0;
        this.detalleColumns = data.length > 0 ? Object.keys(data[0]) : [];
      });
    }
  }
};
</script>

<style scoped>
.cons-remesas-page {
  padding: 20px;
}
.table-hover tbody tr:hover {
  background-color: #f5f5f5;
}
</style>

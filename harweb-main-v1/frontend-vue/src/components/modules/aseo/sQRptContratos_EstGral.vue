<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadístico General de Contratos</li>
      </ol>
    </nav>
    <h2 class="mb-4">Estadístico General de Contratos</h2>
    <div class="form-group mb-3">
      <label for="tipoAseo">Tipo de Aseo:</label>
      <select v-model="selectedTipoAseo" @change="fetchAllData" class="form-control" id="tipoAseo">
        <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
          {{ tipo.descripcion }}
        </option>
      </select>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-else>
      <div class="card mb-4">
        <div class="card-body">
          <h5 class="card-title">Resumen</h5>
          <p><strong>Tipo de Aseo:</strong> {{ tipoAseoDescripcion }}</p>
          <p><strong>Contratos:</strong> {{ contratos.registros || 0 }}</p>
          <p><strong>Vigentes:</strong> {{ contratos_v.registros || 0 }}</p>
          <p><strong>Cancelados:</strong> {{ contratos_c.registros || 0 }}</p>
        </div>
      </div>
      <div class="row">
        <div class="col-md-4">
          <h5>Cuota Normal</h5>
          <table class="table table-sm table-bordered">
            <tbody>
              <tr><th>Registros</th><td>{{ cn.registros || 0 }}</td></tr>
              <tr><th>Importe</th><td>{{ cn.importe || 0 }}</td></tr>
              <tr><th>Vigentes</th><td>{{ cn_v.registros || 0 }}</td></tr>
              <tr><th>Cancelados</th><td>{{ cn_c.registros || 0 }}</td></tr>
              <tr><th>Pagados</th><td>{{ cn_p.registros || 0 }}</td></tr>
              <tr><th>Condonados</th><td>{{ cn_s.registros || 0 }}</td></tr>
            </tbody>
          </table>
        </div>
        <div class="col-md-4">
          <h5>Excedencias</h5>
          <table class="table table-sm table-bordered">
            <tbody>
              <tr><th>Registros</th><td>{{ exe.registros || 0 }}</td></tr>
              <tr><th>Importe</th><td>{{ exe.importe || 0 }}</td></tr>
              <tr><th>Vigentes</th><td>{{ exe_v.registros || 0 }}</td></tr>
              <tr><th>Cancelados</th><td>{{ exe_c.registros || 0 }}</td></tr>
              <tr><th>Pagados</th><td>{{ exe_p.registros || 0 }}</td></tr>
              <tr><th>Condonados</th><td>{{ exe_s.registros || 0 }}</td></tr>
            </tbody>
          </table>
        </div>
        <div class="col-md-4">
          <h5>Contenedores</h5>
          <table class="table table-sm table-bordered">
            <tbody>
              <tr><th>Registros</th><td>{{ con.registros || 0 }}</td></tr>
              <tr><th>Importe</th><td>{{ con.importe || 0 }}</td></tr>
              <tr><th>Vigentes</th><td>{{ con_v.registros || 0 }}</td></tr>
              <tr><th>Cancelados</th><td>{{ con_c.registros || 0 }}</td></tr>
              <tr><th>Pagados</th><td>{{ con_p.registros || 0 }}</td></tr>
              <tr><th>Condonados</th><td>{{ con_s.registros || 0 }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="mt-4">
        <button class="btn btn-primary" @click="fetchAllData">Actualizar</button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'EstadisticoContratos',
  data() {
    return {
      tiposAseo: [],
      selectedTipoAseo: null,
      tipoAseoDescripcion: '',
      contratos: {},
      contratos_v: {},
      contratos_c: {},
      cn: {},
      cn_v: {},
      cn_c: {},
      cn_p: {},
      cn_s: {},
      exe: {},
      exe_v: {},
      exe_c: {},
      exe_p: {},
      exe_s: {},
      con: {},
      con_v: {},
      con_c: {},
      con_p: {},
      con_s: {},
      loading: false
    };
  },
  created() {
    this.fetchTiposAseo();
  },
  methods: {
    async fetchTiposAseo() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            procedure: 'sp_get_tipos_aseo',
            parameters: {}
          }
        });
        this.tiposAseo = res.data.eResponse.data;
        if (this.tiposAseo.length > 0) {
          this.selectedTipoAseo = this.tiposAseo[0].ctrol_aseo;
          this.tipoAseoDescripcion = this.tiposAseo[0].descripcion;
          this.fetchAllData();
        }
      } catch (e) {
        alert('Error cargando tipos de aseo');
      }
      this.loading = false;
    },
    async fetchAllData() {
      if (!this.selectedTipoAseo) return;
      this.loading = true;
      try {
        // Obtener descripción
        const tipo = this.tiposAseo.find(t => t.ctrol_aseo === this.selectedTipoAseo);
        this.tipoAseoDescripcion = tipo ? tipo.descripcion : '';
        // Contratos
        const contratos = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_contratos', parameters: { ctrol: this.selectedTipoAseo } }
        });
        this.contratos = contratos.data.eResponse.data[0] || {};
        const contratos_v = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_contratos_v', parameters: { ctrol: this.selectedTipoAseo } }
        });
        this.contratos_v = contratos_v.data.eResponse.data[0] || {};
        const contratos_c = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_contratos_c', parameters: { ctrol: this.selectedTipoAseo } }
        });
        this.contratos_c = contratos_c.data.eResponse.data[0] || {};
        // Cuota Normal
        const cn = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_cn', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.cn = cn.data.eResponse.data[0] || {};
        const cn_v = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_cn_v', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.cn_v = cn_v.data.eResponse.data[0] || {};
        const cn_c = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_cn_c', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.cn_c = cn_c.data.eResponse.data[0] || {};
        const cn_p = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_cn_p', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.cn_p = cn_p.data.eResponse.data[0] || {};
        const cn_s = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_cn_s', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.cn_s = cn_s.data.eResponse.data[0] || {};
        // Excedencias
        const exe = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_exe', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.exe = exe.data.eResponse.data[0] || {};
        const exe_v = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_exe_v', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.exe_v = exe_v.data.eResponse.data[0] || {};
        const exe_c = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_exe_c', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.exe_c = exe_c.data.eResponse.data[0] || {};
        const exe_p = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_exe_p', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.exe_p = exe_p.data.eResponse.data[0] || {};
        const exe_s = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_exe_s', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.exe_s = exe_s.data.eResponse.data[0] || {};
        // Contenedores
        const con = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_con', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.con = con.data.eResponse.data[0] || {};
        const con_v = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_con_v', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.con_v = con_v.data.eResponse.data[0] || {};
        const con_c = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_con_c', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.con_c = con_c.data.eResponse.data[0] || {};
        const con_p = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_con_p', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.con_p = con_p.data.eResponse.data[0] || {};
        const con_s = await axios.post('/api/execute', {
          eRequest: { procedure: 'sp_get_con_s', parameters: { ctrol_a: this.selectedTipoAseo } }
        });
        this.con_s = con_s.data.eResponse.data[0] || {};
      } catch (e) {
        alert('Error cargando datos: ' + (e.response?.data?.eResponse?.message || e.message));
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.table th, .table td {
  text-align: right;
}
.table th {
  width: 60%;
  text-align: left;
}
</style>

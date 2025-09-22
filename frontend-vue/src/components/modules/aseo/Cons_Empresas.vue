<template>
  <div class="empresas-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Catálogos</span> &gt; <span>Empresas</span>
    </div>
    <div class="panel panel-default mb-3">
      <div class="panel-heading d-flex align-items-center">
        <h3 class="panel-title flex-grow-1">Consulta de Empresas</h3>
        <button class="btn btn-success ml-2" @click="exportExcel">Exportar Excel</button>
        <button class="btn btn-secondary ml-2" @click="goBack">Salir</button>
      </div>
      <div class="panel-body">
        <div class="form-row align-items-end mb-2">
          <div class="form-group col-md-4">
            <label>Buscar por</label>
            <div>
              <label class="mr-2"><input type="radio" value="1" v-model="searchOption"> Por Número</label>
              <label class="mr-2"><input type="radio" value="2" v-model="searchOption"> Por Nombre</label>
              <label><input type="radio" value="3" v-model="searchOption"> Todas</label>
            </div>
          </div>
          <div class="form-group col-md-2" v-if="searchOption == 1">
            <label>Número Empresa</label>
            <input type="number" class="form-control" v-model="numEmpresa" @keyup.enter="buscarEmpresas">
          </div>
          <div class="form-group col-md-3" v-if="searchOption == 1">
            <label>Tipo Empresa</label>
            <select class="form-control" v-model="ctrolEmp">
              <option v-for="tipo in tiposEmp" :key="tipo.ctrol_emp" :value="tipo.ctrol_emp">
                {{ tipo.ctrol_emp }} - {{ tipo.tipo_empresa }} - {{ tipo.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-group col-md-4" v-if="searchOption == 2">
            <label>Nombre Empresa</label>
            <input type="text" class="form-control" v-model="nombreEmpresa" @keyup.enter="buscarEmpresas">
          </div>
          <div class="form-group col-md-2">
            <button class="btn btn-primary" @click="buscarEmpresas">Buscar</button>
          </div>
        </div>
        <div class="table-responsive">
          <table class="table table-bordered table-hover">
            <thead>
              <tr>
                <th>Num. Empresa</th>
                <th>Ctrol. Emp.</th>
                <th>Nombre de la Empresa / Descripción</th>
                <th>Representante</th>
                <th>Tipo</th>
                <th>Tipo Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="empresa in empresas" :key="empresa.num_empresa + '-' + empresa.ctrol_emp">
                <td>{{ empresa.num_empresa }}</td>
                <td>{{ empresa.ctrol_emp }}</td>
                <td>{{ empresa.descripcion }}</td>
                <td>{{ empresa.representante }}</td>
                <td>{{ empresa.tipo_empresa }}</td>
                <td>{{ empresa.descripcion_1 }}</td>
              </tr>
              <tr v-if="empresas.length === 0">
                <td colspan="6" class="text-center">No hay resultados</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EmpresasPage',
  data() {
    return {
      searchOption: '3', // 1: número, 2: nombre, 3: todas
      numEmpresa: '',
      ctrolEmp: '',
      nombreEmpresa: '',
      empresas: [],
      tiposEmp: []
    };
  },
  created() {
    this.cargarTiposEmp();
    this.buscarEmpresas();
  },
  methods: {
    cargarTiposEmp() {
      // Llama al endpoint para obtener tipos de empresa
      axios.post('/api/execute', {
        eRequest: {
          action: 'listTiposEmp',
          params: {}
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          this.tiposEmp = resp.data.eResponse.data;
          if (this.tiposEmp.length > 0) {
            this.ctrolEmp = this.tiposEmp[0].ctrol_emp;
          }
        }
      });
    },
    buscarEmpresas() {
      let action = 'search';
      let params = { opcion: parseInt(this.searchOption) };
      if (this.searchOption == '1') {
        params.num_empresa = this.numEmpresa;
        params.ctrol_emp = this.ctrolEmp;
      } else if (this.searchOption == '2') {
        params.nombre = this.nombreEmpresa;
      }
      axios.post('/api/execute', {
        eRequest: {
          action,
          params
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          this.empresas = resp.data.eResponse.data;
        } else {
          this.empresas = [];
        }
      });
    },
    exportExcel() {
      // Exportar: simplemente descarga los datos actuales como CSV
      let csv = 'Num. Empresa,Ctrol. Emp.,Nombre,Representante,Tipo,Tipo Descripción\n';
      this.empresas.forEach(e => {
        csv += `${e.num_empresa},${e.ctrol_emp},"${e.descripcion}","${e.representante}",${e.tipo_empresa},"${e.descripcion_1}"\n`;
      });
      let blob = new Blob([csv], { type: 'text/csv' });
      let link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = 'empresas.csv';
      link.click();
    },
    goBack() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.empresas-page {
  padding: 20px;
}
.breadcrumb {
  font-size: 14px;
  margin-bottom: 10px;
}
.panel {
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
}
.panel-heading {
  background: #f5f5f5;
  padding: 10px 15px;
  border-bottom: 1px solid #ddd;
  display: flex;
  align-items: center;
}
.panel-title {
  font-size: 18px;
  font-weight: bold;
}
.table {
  margin-bottom: 0;
}
</style>

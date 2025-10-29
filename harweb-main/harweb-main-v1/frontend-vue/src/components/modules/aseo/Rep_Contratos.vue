<template>
  <div class="rep-contratos-page">
    <h1>Reporte de Contratos</h1>
    <div class="breadcrumbs">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span>Contratos</span>
    </div>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label>Empresa:</label>
        <select v-model="empresaId">
          <option :value="null">Todas las empresas</option>
          <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
            {{ emp.num_empresa }} - {{ emp.descripcion }}
          </option>
        </select>
        <button type="button" @click="abrirBusquedaEmpresa">Buscar por nombre</button>
      </div>
      <div class="form-row">
        <label>Tipo de Aseo:</label>
        <select v-model="tipoAseoId">
          <option :value="null">Todos los tipos</option>
          <option v-for="ta in tiposAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Vigencia:</label>
        <select v-model="vigencia">
          <option value="T">Todos</option>
          <option value="V">Vigentes</option>
          <option value="C">Cancelados</option>
        </select>
      </div>
      <div class="form-row">
        <label>Recaudadora:</label>
        <select v-model="recaudadoraId">
          <option :value="null">Todas</option>
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
            {{ rec.id_rec }} - {{ rec.recaudadora }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Tipo de Reporte:</label>
        <select v-model="tipoReporte">
          <option value="empresa_contratos">Empresa - Contratos</option>
          <option value="solo_contratos">Solo Contratos</option>
        </select>
      </div>
      <div class="form-row">
        <label>Orden:</label>
        <select v-model="orden">
          <option value="ctrol_emp,num_empresa">Tipo Emp, Num Emp</option>
          <option value="num_empresa,ctrol_emp">Num Emp, Tipo Emp</option>
          <option value="ctrol_aseo,num_contrato">Tipo Aseo, Num Contrato</option>
        </select>
      </div>
      <div class="form-row">
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="reporte && reporte.length">
      <h2>Resultados</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th v-for="col in columnas" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reporte" :key="row.num_contrato || row.num_empresa">
            <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showBusquedaEmpresa" class="modal">
      <div class="modal-content">
        <h3>Buscar Empresa por Nombre</h3>
        <input v-model="busquedaNombre" @keyup.enter="buscarEmpresasPorNombre" placeholder="Nombre empresa..." />
        <button @click="buscarEmpresasPorNombre">Buscar</button>
        <ul>
          <li v-for="emp in empresasBusqueda" :key="emp.num_empresa">
            <a href="#" @click.prevent="seleccionarEmpresa(emp)">{{ emp.num_empresa }} - {{ emp.descripcion }}</a>
          </li>
        </ul>
        <button @click="showBusquedaEmpresa=false">Cerrar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepContratosPage',
  data() {
    return {
      empresas: [],
      tiposAseo: [],
      recaudadoras: [],
      empresaId: null,
      tipoAseoId: null,
      vigencia: 'T',
      recaudadoraId: null,
      tipoReporte: 'empresa_contratos',
      orden: 'ctrol_emp,num_empresa',
      reporte: [],
      columnas: [],
      loading: false,
      error: '',
      showBusquedaEmpresa: false,
      busquedaNombre: '',
      empresasBusqueda: []
    };
  },
  mounted() {
    this.cargarCombos();
  },
  methods: {
    async cargarCombos() {
      this.loading = true;
      try {
        let [emp, aseo, rec] = await Promise.all([
          this.api('listar_empresas'),
          this.api('listar_tipo_aseo'),
          this.api('listar_recaudadoras')
        ]);
        this.empresas = emp.empresas;
        this.tiposAseo = aseo.tipos_aseo;
        this.recaudadoras = rec.recaudadoras;
      } catch (e) {
        this.error = 'Error cargando combos: ' + e;
      } finally {
        this.loading = false;
      }
    },
    async api(action, params = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, ...params } })
      });
      const data = await res.json();
      if (data.eResponse.error) throw data.eResponse.error;
      return data.eResponse;
    },
    async onBuscar() {
      this.loading = true;
      this.error = '';
      this.reporte = [];
      try {
        let params = {
          empresa_id: this.empresaId,
          tipo_aseo_id: this.tipoAseoId,
          vigencia: this.vigencia,
          recaudadora_id: this.recaudadoraId,
          orden: this.orden
        };
        let action = this.tipoReporte === 'empresa_contratos' ? 'reporte_empresa_contratos' : 'reporte_contratos';
        let resp = await this.api(action, params);
        this.reporte = resp.reporte;
        if (this.reporte.length > 0) {
          this.columnas = Object.keys(this.reporte[0]);
        } else {
          this.columnas = [];
        }
      } catch (e) {
        this.error = 'Error al buscar: ' + e;
      } finally {
        this.loading = false;
      }
    },
    abrirBusquedaEmpresa() {
      this.showBusquedaEmpresa = true;
      this.busquedaNombre = '';
      this.empresasBusqueda = [];
    },
    async buscarEmpresasPorNombre() {
      if (!this.busquedaNombre) return;
      this.loading = true;
      try {
        let resp = await this.api('buscar_empresas', { nombre: this.busquedaNombre });
        this.empresasBusqueda = resp.empresas;
      } catch (e) {
        this.error = 'Error buscando empresas: ' + e;
      } finally {
        this.loading = false;
      }
    },
    seleccionarEmpresa(emp) {
      this.empresaId = emp.num_empresa;
      this.showBusquedaEmpresa = false;
    }
  }
};
</script>

<style scoped>
.rep-contratos-page { max-width: 1100px; margin: 0 auto; padding: 2em; }
.form-row { margin-bottom: 1em; display: flex; align-items: center; }
.form-row label { width: 180px; font-weight: bold; }
.form-row select, .form-row input { flex: 1; }
.table { width: 100%; border-collapse: collapse; margin-top: 2em; }
.table th, .table td { border: 1px solid #ccc; padding: 0.5em; }
.error { color: red; margin: 1em 0; }
.modal { position: fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); display:flex; align-items:center; justify-content:center; }
.modal-content { background:#fff; padding:2em; border-radius:8px; min-width:350px; }
.breadcrumbs { margin-bottom: 1em; color: #666; }
</style>

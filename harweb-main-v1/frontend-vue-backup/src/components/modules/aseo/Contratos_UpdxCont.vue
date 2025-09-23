<template>
  <div class="contratos-updxcont-page">
    <h1>Modificación de Contratos por Número y Tipo de Aseo</h1>
    <form @submit.prevent="onBuscarContrato">
      <div class="form-row">
        <label>No. Contrato:</label>
        <input v-model="form.num_contrato" type="number" required />
        <label>Tipo de Aseo:</label>
        <select v-model="form.ctrol_aseo" required>
          <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
            {{ tipo.ctrol_aseo }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar Contrato</button>
      </div>
    </form>
    <div v-if="contrato">
      <h2>Datos del Contrato</h2>
      <form @submit.prevent="onActualizarContrato">
        <div class="form-row">
          <label>Empresa:</label>
          <input v-model="contrato.num_empresa" type="number" required />
          <button type="button" @click="showEmpresaSearch = true">Buscar Empresa</button>
        </div>
        <div class="form-row">
          <label>Domicilio:</label>
          <input v-model="contrato.domicilio" maxlength="80" required />
        </div>
        <div class="form-row">
          <label>Sector:</label>
          <select v-model="contrato.sector" required>
            <option v-for="s in sectores" :key="s.id" :value="s.id">{{ s.nombre }}</option>
          </select>
        </div>
        <div class="form-row">
          <label>Zona:</label>
          <select v-model="contrato.ctrol_zona" required>
            <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.ctrol_zona">
              {{ z.ctrol_zona }} - {{ z.zona }} - {{ z.sub_zona }} - {{ z.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Recaudadora:</label>
          <select v-model="contrato.id_rec" required>
            <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">
              {{ r.id_rec }} - {{ r.recaudadora }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Documento:</label>
          <input v-model="form.documento" maxlength="15" required />
        </div>
        <div class="form-row">
          <label>Descripción del Documento:</label>
          <textarea v-model="form.descripcion_docto" maxlength="100" required></textarea>
        </div>
        <div class="form-row">
          <button type="submit">Actualizar Contrato</button>
        </div>
      </form>
    </div>
    <div v-if="showEmpresaSearch" class="modal">
      <div class="modal-content">
        <h3>Buscar Empresa</h3>
        <input v-model="empresaSearch" @keyup.enter="onBuscarEmpresa" placeholder="Nombre de empresa" />
        <button @click="onBuscarEmpresa">Buscar</button>
        <ul>
          <li v-for="emp in empresas" :key="emp.num_empresa">
            <a href="#" @click.prevent="onSeleccionarEmpresa(emp)">
              {{ emp.num_empresa }} - {{ emp.descripcion }} ({{ emp.representante }})
            </a>
          </li>
        </ul>
        <button @click="showEmpresaSearch = false">Cerrar</button>
      </div>
    </div>
    <div v-if="message" class="message">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosUpdxContPage',
  data() {
    return {
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        documento: '',
        descripcion_docto: ''
      },
      tiposAseo: [],
      zonas: [],
      recaudadoras: [],
      sectores: [],
      contrato: null,
      showEmpresaSearch: false,
      empresaSearch: '',
      empresas: [],
      message: '',
      usuario: 1 // Simulación de usuario logueado
    };
  },
  created() {
    this.loadCombos();
  },
  methods: {
    async loadCombos() {
      // Cargar tipos de aseo
      let res = await this.api('listarTipoAseo');
      this.tiposAseo = res;
      if (this.tiposAseo.length > 0) {
        this.form.ctrol_aseo = this.tiposAseo[0].ctrol_aseo;
      }
      // Cargar sectores
      res = await this.api('listarSectores');
      this.sectores = res;
      // Cargar zonas
      res = await this.api('listarZonas');
      this.zonas = res;
      // Cargar recaudadoras
      res = await this.api('listarRecaudadoras');
      this.recaudadoras = res;
    },
    async api(operation, params = {}) {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { operation, ...params } })
      });
      const data = await resp.json();
      if (data.eResponse && data.eResponse.error) {
        this.message = data.eResponse.error;
        throw new Error(data.eResponse.error);
      }
      return data.eResponse;
    },
    async onBuscarContrato() {
      this.message = '';
      try {
        const res = await this.api('buscarContrato', {
          num_contrato: this.form.num_contrato,
          ctrol_aseo: this.form.ctrol_aseo
        });
        if (!res.found) {
          this.contrato = null;
          this.message = res.message;
        } else {
          this.contrato = res.contrato;
          this.zonas = res.zonas;
          this.recaudadoras = res.recaudadoras;
          this.sectores = res.sectores;
        }
      } catch (e) {}
    },
    async onBuscarEmpresa() {
      this.message = '';
      try {
        const res = await this.api('buscarEmpresa', { nombre: this.empresaSearch });
        this.empresas = res.empresas;
        if (this.empresas.length === 0) {
          if (confirm('No existe empresa alguna. ¿Deseas darla de alta con este dato capturado?')) {
            const alta = await this.api('altaEmpresa', { nombre: this.empresaSearch });
            this.empresas = [alta.empresa];
          }
        }
      } catch (e) {}
    },
    onSeleccionarEmpresa(emp) {
      this.contrato.num_empresa = emp.num_empresa;
      this.showEmpresaSearch = false;
    },
    async onActualizarContrato() {
      this.message = '';
      try {
        const payload = {
          control_contrato: this.contrato.control_contrato,
          num_empresa: this.contrato.num_empresa,
          ctrol_emp: 9, // Fijo para privadas
          domicilio: this.contrato.domicilio,
          sector: this.contrato.sector,
          ctrol_zona: this.contrato.ctrol_zona,
          id_rec: this.contrato.id_rec,
          documento: this.form.documento,
          descripcion_docto: this.form.descripcion_docto,
          usuario: this.usuario
        };
        const res = await this.api('actualizarContrato', payload);
        this.message = res.message;
      } catch (e) {}
    }
  }
};
</script>

<style scoped>
.contratos-updxcont-page {
  max-width: 800px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
}
.form-row {
  margin-bottom: 1em;
  display: flex;
  align-items: center;
  gap: 1em;
}
.message {
  margin-top: 1em;
  color: #b00;
}
.modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-content {
  background: #fff;
  padding: 2em;
  border-radius: 8px;
  min-width: 400px;
}
</style>

<template>
  <div class="contratos-upd01-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Actualización de Contratos</span>
    </nav>
    <h1>Actualización de Contratos</h1>
    <form @submit.prevent="buscarContrato">
      <div class="form-row">
        <label for="contrato">Contrato</label>
        <input v-model="form.num_contrato" id="contrato" maxlength="10" required />
        <label for="tipoAseo">Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" id="tipoAseo" required>
          <option v-for="ta in tipoAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="contrato">
      <div class="form-row">
        <label>Actualización a realizar:</label>
        <select v-model="opcion">
          <option v-for="(op, idx) in opciones" :key="idx" :value="idx">{{ op }}</option>
        </select>
      </div>
      <component :is="currentFormComponent" :contrato="contrato" :auxData="auxData" @actualizar="actualizarContrato" />
    </div>
    <div v-if="mensaje" class="mensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
import axios from 'axios';

// Importar subcomponentes para cada formulario (uno por opción)
import FormUnidadRecoleccion from './ContratosUpd01/FormUnidadRecoleccion.vue';
import FormInicioObligacion from './ContratosUpd01/FormInicioObligacion.vue';
import FormCantidadRecoleccion from './ContratosUpd01/FormCantidadRecoleccion.vue';
import FormEmpresa from './ContratosUpd01/FormEmpresa.vue';
import FormDomicilio from './ContratosUpd01/FormDomicilio.vue';
import FormZona from './ContratosUpd01/FormZona.vue';
import FormSector from './ContratosUpd01/FormSector.vue';
import FormRecaudadora from './ContratosUpd01/FormRecaudadora.vue';
import FormLicenciasGiro from './ContratosUpd01/FormLicenciasGiro.vue';

export default {
  name: 'ContratosUpd01Page',
  components: {
    FormUnidadRecoleccion,
    FormInicioObligacion,
    FormCantidadRecoleccion,
    FormEmpresa,
    FormDomicilio,
    FormZona,
    FormSector,
    FormRecaudadora,
    FormLicenciasGiro
  },
  data() {
    return {
      tipoAseo: [],
      unidades: [],
      zonas: [],
      recaudadoras: [],
      empresas: [],
      contrato: null,
      auxData: {},
      form: {
        num_contrato: '',
        ctrol_aseo: ''
      },
      opcion: 0,
      opciones: [
        'Unidad de Recolección',
        'Inicio de Obligación',
        'Cantidad a Recolectar',
        'Empresa',
        'Domicilio',
        'Zona',
        'Sector',
        'Recaudadora',
        'Licencias de Giro'
      ],
      mensaje: ''
    };
  },
  computed: {
    currentFormComponent() {
      const map = [
        'FormUnidadRecoleccion',
        'FormInicioObligacion',
        'FormCantidadRecoleccion',
        'FormEmpresa',
        'FormDomicilio',
        'FormZona',
        'FormSector',
        'FormRecaudadora',
        'FormLicenciasGiro'
      ];
      return map[this.opcion];
    }
  },
  methods: {
    async cargarCatalogos() {
      // Cargar catálogos necesarios
      const [tipoAseo, unidades, zonas, recaudadoras] = await Promise.all([
        this.api('getTipoAseo'),
        this.api('getUnidades', { ejercicio: new Date().getFullYear() }),
        this.api('getZonas'),
        this.api('getRecaudadoras')
      ]);
      this.tipoAseo = tipoAseo;
      this.unidades = unidades;
      this.zonas = zonas;
      this.recaudadoras = recaudadoras;
    },
    async buscarContrato() {
      this.mensaje = '';
      try {
        const res = await this.api('buscarContrato', {
          num_contrato: this.form.num_contrato,
          ctrol_aseo: this.form.ctrol_aseo
        });
        if (res && res.length > 0) {
          this.contrato = res[0];
          await this.cargarAuxData();
        } else {
          this.contrato = null;
          this.mensaje = 'No se encontró el contrato.';
        }
      } catch (e) {
        this.mensaje = 'Error al buscar contrato: ' + e;
      }
    },
    async cargarAuxData() {
      // Cargar empresas, licencias, etc según opción
      if (this.opcion === 3) {
        // Empresa
        this.empresas = await this.api('buscarEmpresas', { nombre: '' });
        this.auxData.empresas = this.empresas;
      }
      if (this.opcion === 8) {
        // Licencias relacionadas
        this.auxData.licencias = await this.api('verLicenciasRelacionadas', { control_contrato: this.contrato.control_contrato });
      }
    },
    async actualizarContrato(payload) {
      try {
        const res = await this.api('actualizarContrato', payload);
        if (res && res[0] && res[0].concepto) {
          this.mensaje = res[0].concepto;
          await this.buscarContrato();
        } else {
          this.mensaje = 'Actualización realizada.';
        }
      } catch (e) {
        this.mensaje = 'Error al actualizar: ' + e;
      }
    },
    async api(action, data = {}) {
      const resp = await axios.post('/api/execute', {
        eRequest: { action, data }
      });
      if (resp.data && resp.data.eResponse && !resp.data.eResponse.error) {
        return resp.data.eResponse;
      } else {
        throw resp.data.eResponse.error || 'Error desconocido';
      }
    }
  },
  mounted() {
    this.cargarCatalogos();
  },
  watch: {
    opcion() {
      this.cargarAuxData();
    }
  }
};
</script>

<style scoped>
.contratos-upd01-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.mensaje {
  margin-top: 1rem;
  color: #b00;
}
</style>

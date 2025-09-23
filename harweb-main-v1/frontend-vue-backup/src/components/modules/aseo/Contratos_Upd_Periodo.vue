<template>
  <div class="contratos-upd-periodo-page">
    <h1>Actualización del Periodo de Inicio de Obligación (Contratos)</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / <span>Contratos</span> / <span>Actualizar Periodo de Obligación</span>
    </div>
    <form @submit.prevent="buscarContrato">
      <div class="form-row">
        <label for="num_contrato">No. Contrato</label>
        <input v-model="form.num_contrato" id="num_contrato" maxlength="10" required />
        <label for="ctrol_aseo">Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" id="ctrol_aseo" required>
          <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
            {{ tipo.ctrol_aseo.toString().padStart(3, '0') }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="contrato" class="contrato-info">
      <h2>Datos del Contrato</h2>
      <table class="info-table">
        <tr><th>Control Contrato</th><td>{{ contrato.control_contrato }}</td></tr>
        <tr><th>No. Contrato</th><td>{{ contrato.num_contrato }}</td></tr>
        <tr><th>Empresa</th><td>{{ contrato.descripcion_1 }}</td></tr>
        <tr><th>Representante</th><td>{{ contrato.representante }}</td></tr>
        <tr><th>Tipo de Aseo</th><td>{{ contrato.tipo_aseo }} - {{ contrato.descripcion_2 }}</td></tr>
        <tr><th>Inicio Obligación</th><td>{{ contrato.aso_mes_oblig | formatPeriodo }}</td></tr>
        <tr><th>Vigencia</th><td>{{ contrato.status_vigencia }}</td></tr>
      </table>
      <form @submit.prevent="actualizarPeriodo">
        <fieldset>
          <legend>Actualizar Periodo de Inicio de Obligación</legend>
          <div class="form-row">
            <label for="anio">Año</label>
            <input v-model="form.anio" id="anio" maxlength="4" required />
            <label for="mes">Mes</label>
            <select v-model="form.mes" id="mes" required>
              <option v-for="m in 12" :key="m" :value="m.toString().padStart(2, '0')">{{ m.toString().padStart(2, '0') }}</option>
            </select>
          </div>
          <div class="form-row">
            <label for="documento">Documento</label>
            <input v-model="form.documento" id="documento" maxlength="15" required />
            <label for="descripcion">Descripción</label>
            <textarea v-model="form.descripcion" id="descripcion" maxlength="100" required></textarea>
          </div>
          <button type="submit">Actualizar Periodo</button>
        </fieldset>
      </form>
      <div v-if="resultMessage" :class="{'success': resultStatus === 0, 'error': resultStatus !== 0}">
        {{ resultMessage }}
      </div>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ContratosUpdPeriodoPage',
  data() {
    return {
      tiposAseo: [],
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        anio: '',
        mes: '01',
        documento: '',
        descripcion: ''
      },
      contrato: null,
      error: '',
      resultMessage: '',
      resultStatus: null
    };
  },
  filters: {
    formatPeriodo(val) {
      if (!val) return '';
      const d = new Date(val);
      return d.getFullYear() + '-' + (d.getMonth() + 1).toString().padStart(2, '0');
    }
  },
  created() {
    this.cargarTiposAseo();
  },
  methods: {
    async cargarTiposAseo() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'catalogoTipoAseo' })
        });
        const data = await res.json();
        if (data.success) {
          this.tiposAseo = data.data;
        }
      } catch (e) {
        this.error = 'Error cargando tipos de aseo';
      }
    },
    async buscarContrato() {
      this.error = '';
      this.resultMessage = '';
      this.resultStatus = null;
      this.contrato = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscarContrato',
            params: {
              num_contrato: this.form.num_contrato,
              ctrol_aseo: this.form.ctrol_aseo
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.contrato = data.data;
          // Prellenar año/mes con el periodo actual
          if (this.contrato && this.contrato.aso_mes_oblig) {
            const d = new Date(this.contrato.aso_mes_oblig);
            this.form.anio = d.getFullYear().toString();
            this.form.mes = (d.getMonth() + 1).toString().padStart(2, '0');
          }
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = 'Error buscando contrato';
      }
    },
    async actualizarPeriodo() {
      this.error = '';
      this.resultMessage = '';
      this.resultStatus = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'actualizarPeriodoObligacion',
            params: {
              control_contrato: this.contrato.control_contrato,
              anio: this.form.anio,
              mes: this.form.mes,
              documento: this.form.documento,
              descripcion: this.form.descripcion
            }
          })
        });
        const data = await res.json();
        this.resultMessage = data.message;
        this.resultStatus = data.status;
        if (data.success && data.status === 0) {
          this.buscarContrato();
        }
      } catch (e) {
        this.error = 'Error actualizando periodo';
      }
    }
  }
};
</script>

<style scoped>
.contratos-upd-periodo-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.9rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.info-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.info-table th, .info-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
fieldset {
  border: 1px solid #aaa;
  padding: 1rem;
  margin-bottom: 1rem;
}
.success {
  color: green;
  font-weight: bold;
}
.error {
  color: red;
  font-weight: bold;
}
</style>

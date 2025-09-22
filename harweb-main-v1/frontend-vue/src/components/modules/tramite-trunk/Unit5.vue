<template>
  <div class="unit5-form-page">
    <h1>Captura de los Datos Generales de la Transmisión de Dominio</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Cuenta catastral</label>
        <input v-model="form.cuenta" disabled />
        <label>Clave catastral</label>
        <input v-model="form.cvecatnva" disabled />
        <label>SubPredio</label>
        <input v-model="form.subpredio" disabled />
      </div>
      <div class="form-row">
        <label>Año de efectos</label>
        <input v-model.number="form.axoefec" type="number" @blur="onAxoefecBlur" required />
        <label>Bim. efectos</label>
        <input v-model.number="form.bimefec" type="number" min="1" max="6" @blur="onBimefecBlur" required />
        <label>Porcentaje de transmisión</label>
        <input v-model.number="form.porcbase" type="number" min="0" max="100" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Numero notario</label>
        <input v-model="form.notaria" disabled />
        <label>Notario</label>
        <select v-model="form.idnotaria" @change="onNotarioChange">
          <option v-for="n in notarios" :key="n.idnotaria" :value="n.idnotaria">{{ n.nnotario }} - {{ n.nombre }}</option>
        </select>
        <label>Municipio adscripción</label>
        <input v-model="form.municipio" disabled />
      </div>
      <div class="form-row">
        <label>Escritura</label>
        <input v-model="form.noescrituras" required />
        <label>Lugar otorgamiento</label>
        <select v-model="form.lugotorg">
          <option v-for="m in municipios" :key="m.cvemunicipio" :value="m.cvemunicipio">{{ m.municipio }}</option>
        </select>
        <label>Naturaleza del Acto</label>
        <select v-model="form.naturaleza" @change="onNaturalezaChange">
          <option v-for="n in naturalezas" :key="n.idacto" :value="n.idacto">{{ n.descripcion }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Fecha otorgamiento</label>
        <input v-model="form.fechaotorg" type="date" :disabled="!fechaOtorgEnabled" required />
        <label>Fecha firma</label>
        <input v-model="form.fechafirma" type="date" :disabled="!fechaFirmaEnabled" />
        <label>Fecha resolución</label>
        <input v-model="form.fechaadjudicacion" type="date" :disabled="!fechaResolEnabled" />
      </div>
      <div class="form-row">
        <label>Valor de la Operación</label>
        <input v-model.number="form.valortransm" type="number" min="0" step="0.01" required />
        <label>Valor del Avalúo</label>
        <input v-model.number="form.valfemi" type="number" min="0" step="0.01" disabled />
        <label>Valor Fiscal</label>
        <input v-model.number="form.valfiscal" type="number" min="0" step="0.01" disabled />
        <label>Tasa Predial</label>
        <input v-model="form.tasaemi" disabled />
      </div>
      <div class="form-row">
        <label>Superficie según Título</label>
        <input v-model.number="form.areatitulo" type="number" min="0" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Información Adicional</label>
        <textarea v-model="form.documentosotros" rows="3"></textarea>
      </div>
      <div class="form-row">
        <button type="submit">Guardar</button>
      </div>
      <div v-if="error" class="error">{{ error }}</div>
      <div v-if="success" class="success">Guardado correctamente</div>
    </form>
    <section class="avaluos-section">
      <h2>Avalúos Externos</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Cve Avalúo</th>
            <th>Sup Terr</th>
            <th>Año Folio</th>
            <th>Folio</th>
            <th>Val Avalúo</th>
            <th>Fecha Aprob</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in avaluos" :key="a.cveavaext">
            <td>{{ a.cveavaext }}</td>
            <td>{{ a.supterr }}</td>
            <td>{{ a.axofolio }}</td>
            <td>{{ a.folio }}</td>
            <td>{{ a.valava }}</td>
            <td>{{ a.fecaprob }}</td>
          </tr>
        </tbody>
      </table>
      <div class="valoresref">
        <label>Valor Referenciado:</label>
        <span>{{ valoresref.valor || '-' }}</span>
      </div>
    </section>
  </div>
</template>

<script>
import api from '@/api'; // Suponiendo helper para /api/execute
export default {
  name: 'Unit5FormPage',
  data() {
    return {
      form: {
        cuenta: '',
        cvecatnva: '',
        subpredio: '',
        axoefec: '',
        bimefec: '',
        porcbase: 100,
        notaria: '',
        idnotaria: '',
        municipio: '',
        lugotorg: '',
        naturaleza: '',
        fechaotorg: '',
        fechafirma: '',
        fechaadjudicacion: '',
        noescrituras: '',
        valortransm: '',
        valfemi: '',
        valfiscal: '',
        tasaemi: '',
        areatitulo: '',
        documentosotros: ''
      },
      notarios: [],
      municipios: [],
      naturalezas: [],
      avaluos: [],
      valoresref: {},
      error: '',
      success: false,
      fechaOtorgEnabled: true,
      fechaFirmaEnabled: false,
      fechaResolEnabled: false
    };
  },
  created() {
    this.loadFormData();
  },
  methods: {
    async loadFormData() {
      try {
        const cvecuenta = this.$route.query.cvecuenta || '';
        const res = await api.post('/api/execute', {
          action: 'getFormData',
          params: { cvecuenta }
        });
        if (res.data.success) {
          const d = res.data.data;
          this.form.cuenta = d.cuenta.claveutm;
          this.form.cvecatnva = d.cuenta.cvecatnva;
          this.form.subpredio = d.cuenta.subpredio;
          this.notarios = d.notarios;
          this.municipios = d.municipios;
          this.naturalezas = d.naturalezas;
          this.avaluos = d.avaluos;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async onAxoefecBlur() {
      // Filtrar avaluos externos >= axoefec
      try {
        const res = await api.post('/api/execute', {
          action: 'getAvaluosExternos',
          params: {
            cvecuenta: this.form.cuenta,
            axoefec: this.form.axoefec
          }
        });
        if (res.data.success) {
          this.avaluos = res.data.data;
        }
      } catch (e) {}
    },
    async onBimefecBlur() {
      // Buscar valores referenciados
      try {
        const res = await api.post('/api/execute', {
          action: 'getValoresReferenciados',
          params: {
            cveavaext: this.form.cveavaext,
            axoefec: this.form.axoefec,
            bimefec: this.form.bimefec
          }
        });
        if (res.data.success) {
          this.valoresref = res.data.data;
          if (this.valoresref && this.valoresref.valor) {
            this.form.valfemi = this.valoresref.valor;
          }
        }
      } catch (e) {}
    },
    onNotarioChange() {
      // Actualiza municipio
      const notario = this.notarios.find(n => n.idnotaria === this.form.idnotaria);
      if (notario) {
        this.form.municipio = notario.municipio;
        this.form.lugotorg = notario.cvemunicipio;
      }
    },
    onNaturalezaChange() {
      // Habilita/deshabilita fechas según naturaleza
      const n = this.form.naturaleza;
      if ([3,4,5,6,16,26,28].includes(Number(n))) {
        this.fechaOtorgEnabled = true;
        this.fechaFirmaEnabled = false;
        this.fechaResolEnabled = true;
      } else {
        this.fechaOtorgEnabled = true;
        this.fechaFirmaEnabled = true;
        this.fechaResolEnabled = false;
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = false;
      try {
        // Validación básica
        if (!this.form.axoefec || this.form.axoefec < 1960 || this.form.axoefec > 3000) {
          this.error = 'Revise el año...'; return;
        }
        if (!this.form.bimefec || this.form.bimefec < 1 || this.form.bimefec > 6) {
          this.error = 'Revise el bimestre...'; return;
        }
        if (!this.form.porcbase || this.form.porcbase < 0 || this.form.porcbase > 100) {
          this.error = 'Revise el porcentaje...'; return;
        }
        if (!this.form.idnotaria) {
          this.error = 'Especifique un notario...'; return;
        }
        if (!this.form.fechaotorg && ([3,4,5,6,16,26,28].indexOf(Number(this.form.naturaleza)) === -1)) {
          this.error = 'Revise la fecha de otorgamiento...'; return;
        }
        if (!this.form.fechafirma && ([3,4,5,6,16,26,28].indexOf(Number(this.form.naturaleza)) === -1)) {
          this.error = 'Revise la fecha de firma...'; return;
        }
        if (!this.form.fechaadjudicacion && ([3,4,5,6,16,26,28].indexOf(Number(this.form.naturaleza)) !== -1)) {
          this.error = 'Revise la fecha de resolución...'; return;
        }
        if (!this.form.noescrituras) {
          this.error = 'Revise el no. de escritura...'; return;
        }
        if (!this.form.lugotorg) {
          this.error = 'Especifique un lugar de otorgamiento...'; return;
        }
        if (!this.form.naturaleza) {
          this.error = 'Especifique la naturaleza del acto...'; return;
        }
        if (!this.form.valortransm || this.form.valortransm <= 0) {
          this.error = 'Especifique el valor de la transmisión...'; return;
        }
        // Guardar
        const res = await api.post('/api/execute', {
          action: 'saveTransmision',
          params: this.form
        });
        if (res.data.success) {
          this.success = true;
        } else {
          this.error = res.data.message || 'Error al guardar';
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.unit5-form-page {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}
.form-row label {
  min-width: 120px;
  font-weight: bold;
}
.form-row input, .form-row select, .form-row textarea {
  flex: 1 1 180px;
  padding: 0.3rem;
}
.error { color: #c00; margin-top: 1rem; }
.success { color: #080; margin-top: 1rem; }
.avaluos-section { margin-top: 2rem; }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { border: 1px solid #ccc; padding: 0.3rem; }
.valoresref { margin-top: 1rem; font-weight: bold; }
</style>

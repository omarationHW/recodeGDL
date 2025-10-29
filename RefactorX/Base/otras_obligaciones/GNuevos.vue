<template>
  <div class="gnuevos-page">
    <h1>{{ nombreTabla ? 'ALTA DE: ' + nombreTabla : 'Alta de Nuevo Registro' }}</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <form v-else @submit.prevent="onSubmit">
      <div class="form-row">
        <label :for="campoBusquedaId">{{ seleccionBusqueda }}</label>
        <input v-if="showNumExpN" v-model="form.numExpN" :id="campoBusquedaId" maxlength="10" required @keyup.enter="focusNext('concesionario')" />
        <input v-if="showLocalNum" v-model="form.localNum" maxlength="3" required @keyup.enter="focusNext('letra')" />
        <input v-if="showLetra" v-model="form.letra" maxlength="2" @keyup.enter="focusNext('concesionario')" />
      </div>
      <div class="form-row">
        <label for="concesionario">{{ etiquetas.concesionario || 'Concesionario' }}</label>
        <input v-model="form.concesionario" id="concesionario" maxlength="200" required @keyup.enter="focusNext('ubicacion')" />
      </div>
      <div class="form-row">
        <label for="ubicacion">{{ etiquetas.ubicacion || 'Ubicación' }}</label>
        <input v-model="form.ubicacion" id="ubicacion" maxlength="200" required @keyup.enter="focusNext('nomComercial')" />
      </div>
      <div class="form-row">
        <label for="nomComercial">{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}</label>
        <input v-model="form.nomComercial" id="nomComercial" maxlength="200" @keyup.enter="focusNext('lugar')" />
      </div>
      <div class="form-row">
        <label for="lugar">{{ etiquetas.lugar || 'Lugar' }}</label>
        <input v-model="form.lugar" id="lugar" maxlength="200" @keyup.enter="focusNext('obs')" />
      </div>
      <div class="form-row">
        <label for="obs">{{ etiquetas.obs || 'Observaciones' }}</label>
        <input v-model="form.obs" id="obs" maxlength="200" @keyup.enter="focusNext('superficie')" />
      </div>
      <div class="form-row" v-if="showSuperficie">
        <label for="superficie">{{ etiquetas.superficie || 'Superficie (m2)' }}</label>
        <input v-model.number="form.superficie" id="superficie" type="number" min="1" step="0.01" required @keyup.enter="focusNext('tipoLocal')" />
      </div>
      <div class="form-row">
        <label for="tipoLocal">{{ etiquetas.unidad || 'Tipo' }}</label>
        <select v-model="form.tipoLocal" id="tipoLocal">
          <option v-for="tipo in tiposLocal" :key="tipo" :value="tipo">{{ tipo }}</option>
        </select>
      </div>
      <div class="form-row">
        <label for="ofna">{{ etiquetas.recaudadora || 'Recaudadora' }}</label>
        <input v-model.number="form.ofna" id="ofna" type="number" min="1" required @keyup.enter="focusNext('sector')" />
        <label for="sector">{{ etiquetas.sector || 'Sector' }}</label>
        <input v-model="form.sector" id="sector" maxlength="2" @keyup.enter="focusNext('zona')" />
        <label for="zona">{{ etiquetas.zona || 'Zona' }}</label>
        <input v-model.number="form.zona" id="zona" type="number" min="1" required @keyup.enter="focusNext('licencia')" />
      </div>
      <div class="form-row">
        <label for="licencia">{{ etiquetas.licencia || 'Licencia' }}</label>
        <input v-model.number="form.licencia" id="licencia" type="number" min="1" required @keyup.enter="focusNext('aso')" />
      </div>
      <div class="form-row">
        <label for="aso">Año de Inicio de Obligación</label>
        <input v-model.number="form.aso" id="aso" type="number" min="2020" max="2099" required @keyup.enter="focusNext('mes')" />
        <label for="mes">Mes</label>
        <select v-model.number="form.mes" id="mes">
          <option v-for="m in 12" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
        </select>
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="submitting">{{ submitting ? 'Guardando...' : 'Aplicar' }}</button>
        <button type="button" @click="resetForm">Cancelar</button>
      </div>
      <div v-if="error" class="error">{{ error }}</div>
      <div v-if="success" class="success">{{ success }}</div>
    </form>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'GNuevosPage',
  data() {
    return {
      loading: true,
      submitting: false,
      error: '',
      success: '',
      gloOpc: 3, // Por defecto, puede venir de la ruta o props
      nombreTabla: '',
      seleccionBusqueda: '',
      etiquetas: {},
      tiposLocal: [],
      showNumExpN: false,
      showLocalNum: false,
      showLetra: false,
      showSuperficie: true,
      form: {
        numExpN: '',
        localNum: '',
        letra: '',
        concesionario: '',
        ubicacion: '',
        nomComercial: '',
        lugar: '',
        obs: '',
        superficie: 1,
        tipoLocal: '',
        ofna: '',
        sector: '',
        zona: '',
        licencia: '',
        aso: '',
        mes: 1
      }
    };
  },
  computed: {
    campoBusquedaId() {
      return this.showNumExpN ? 'numExpN' : (this.showLocalNum ? 'localNum' : '');
    }
  },
  mounted() {
    this.initForm();
  },
  methods: {
    async initForm() {
      try {
        this.loading = true;
        // 1. Obtener etiquetas
        const etqRes = await axios.post('/api/execute', {
          action: 'GNuevos.getEtiquetas',
          params: { par_tab: this.gloOpc }
        });
        this.etiquetas = etqRes.data.data || {};
        // 2. Obtener catálogo de tipos de local
        const catRes = await axios.post('/api/execute', {
          action: 'GNuevos.getCatalogs',
          params: { par_tab: this.gloOpc }
        });
        this.tiposLocal = catRes.data.data.tipos_local || [];
        this.form.tipoLocal = this.tiposLocal[0] || '';
        // 3. Obtener nombre de tabla y lógica de campos
        // Simulación: en real, pedir a backend si necesario
        this.nombreTabla = this.etiquetas.nombre || 'Tabla';
        this.seleccionBusqueda = 'REGISTRO POR: ' + (this.etiquetas.etiq_control || 'Control');
        // Lógica de campos visibles según gloOpc
        if ([1,2,4,5].includes(this.gloOpc)) {
          this.showNumExpN = true;
          this.showLocalNum = false;
          this.showLetra = false;
        } else if (this.gloOpc === 3) {
          this.showNumExpN = false;
          this.showLocalNum = true;
          this.showLetra = true;
        }
        if ([1,2,3,4].includes(this.gloOpc)) {
          this.showSuperficie = true;
        } else {
          this.showSuperficie = false;
          this.form.superficie = 1;
        }
      } catch (e) {
        this.error = 'Error al cargar datos iniciales: ' + (e.response?.data?.error || e.message);
      } finally {
        this.loading = false;
      }
    },
    focusNext(field) {
      this.$nextTick(() => {
        const el = this.$el.querySelector(`#${field}`);
        if (el) el.focus();
      });
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      this.submitting = true;
      try {
        // Validaciones mínimas
        if (this.showNumExpN && (!this.form.numExpN || this.form.numExpN === '0')) {
          this.error = 'Falta el dato del NUMERO DE EXPEDIENTE';
          return;
        }
        if (this.showLocalNum && (!this.form.localNum || this.form.localNum === '0')) {
          this.error = 'Falta el dato del NUMERO DE LOCAL';
          return;
        }
        if (!this.form.concesionario) {
          this.error = 'Falta el dato del CONCESIONARIO';
          return;
        }
        if (!this.form.ubicacion) {
          this.error = 'Falta el dato de la UBICACION';
          return;
        }
        if (this.showSuperficie && (!this.form.superficie || this.form.superficie <= 0)) {
          this.error = 'Falta el dato de la SUPERFICIE';
          return;
        }
        if (!this.form.licencia) {
          this.error = 'Falta el dato de la LICENCIA';
          return;
        }
        if (!this.form.aso || this.form.aso < 2020) {
          this.error = 'Falta el dato del AÑO de inicio de OBLIGACION';
          return;
        }
        // Construir par_control
        let par_control = '';
        if (this.gloOpc === 3) {
          par_control = this.form.localNum + (this.form.letra ? '-' + this.form.letra : '');
        } else {
          par_control = (this.etiquetas.abreviatura || '') + this.form.numExpN;
        }
        // Llamar API
        const res = await axios.post('/api/execute', {
          action: 'GNuevos.create',
          params: {
            par_tabla: this.gloOpc,
            par_control,
            par_conces: this.form.concesionario,
            par_ubica: this.form.ubicacion,
            par_sup: this.form.superficie,
            par_Axo_Ini: this.form.aso,
            par_Mes_Ini: this.form.mes,
            par_ofna: this.form.ofna,
            par_sector: this.form.sector,
            par_zona: this.form.zona,
            par_lic: this.form.licencia,
            par_Descrip: this.form.tipoLocal,
            par_NomCom: this.form.nomComercial,
            par_Lugar: this.form.lugar,
            par_Obs: this.form.obs,
            par_usuario: 'usuario_actual' // Reemplazar por usuario real
          }
        });
        if (res.data.success && res.data.data.status === 1) {
          this.success = res.data.data.concepto_status || 'Registro creado correctamente';
          this.resetForm();
        } else {
          this.error = res.data.data.concepto_status || 'Error al crear registro';
        }
      } catch (e) {
        this.error = e.response?.data?.error || e.message;
      } finally {
        this.submitting = false;
      }
    },
    resetForm() {
      this.form = {
        numExpN: '',
        localNum: '',
        letra: '',
        concesionario: '',
        ubicacion: '',
        nomComercial: '',
        lugar: '',
        obs: '',
        superficie: 1,
        tipoLocal: this.tiposLocal[0] || '',
        ofna: '',
        sector: '',
        zona: '',
        licencia: '',
        aso: '',
        mes: 1
      };
      this.error = '';
      this.success = '';
    }
  }
};
</script>

<style scoped>
.gnuevos-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  min-width: 140px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  margin-right: 1rem;
  padding: 0.3rem 0.5rem;
}
.form-actions {
  margin-top: 2rem;
  display: flex;
  gap: 1rem;
}
.error {
  color: #b00;
  margin-top: 1rem;
}
.success {
  color: #080;
  margin-top: 1rem;
}
.loading {
  text-align: center;
  font-size: 1.2em;
}
</style>

<template>
  <div class="r-nuevos-page">
    <h1>Alta de Locales</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Alta de Locales</li>
      </ol>
    </nav>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="numero">Número de Local</label>
          <input v-model="form.numero" id="numero" type="text" maxlength="3" class="form-control" required @keypress="onlyDigits($event, 3)" />
        </div>
        <div class="form-group col-md-2">
          <label for="letra">Letra</label>
          <input v-model="form.letra" id="letra" type="text" maxlength="1" class="form-control" style="text-transform:uppercase" />
        </div>
      </div>
      <div class="form-group">
        <label for="concesionario">Concesionario</label>
        <input v-model="form.concesionario" id="concesionario" type="text" maxlength="200" class="form-control" required style="text-transform:uppercase" />
      </div>
      <div class="form-group">
        <label for="ubicacion">Ubicación</label>
        <input v-model="form.ubicacion" id="ubicacion" type="text" maxlength="200" class="form-control" required style="text-transform:uppercase" />
      </div>
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="superficie">Superficie (m²)</label>
          <input v-model="form.superficie" id="superficie" type="number" min="1" step="0.01" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="licencia">No. Licencia</label>
          <input v-model="form.licencia" id="licencia" type="text" maxlength="7" class="form-control" required @keypress="onlyDigits($event, 7)" />
        </div>
        <div class="form-group col-md-3">
          <label for="tipo_local">Tipo de Local</label>
          <select v-model="form.tipo_local" id="tipo_local" class="form-control">
            <option v-for="tipo in tiposLocal" :key="tipo" :value="tipo">{{ tipo }}</option>
          </select>
        </div>
      </div>
      <fieldset class="border p-2 mb-3">
        <legend class="w-auto">Periodo de Inicio de Obligación</legend>
        <div class="form-row">
          <div class="form-group col-md-3">
            <label for="aso">Año</label>
            <input v-model="form.aso" id="aso" type="text" maxlength="4" class="form-control" required @keypress="onlyDigits($event, 4)" />
          </div>
          <div class="form-group col-md-3">
            <label for="mes">Mes</label>
            <select v-model="form.mes" id="mes" class="form-control">
              <option v-for="(m, idx) in meses" :key="idx" :value="m.value">{{ m.label }}</option>
            </select>
          </div>
        </div>
      </fieldset>
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="ofna">Recaudadora</label>
          <input v-model="form.ofna" id="ofna" type="text" class="form-control" disabled />
        </div>
        <div class="form-group col-md-2">
          <label for="sector">Sector</label>
          <input v-model="form.sector" id="sector" type="text" class="form-control" disabled />
        </div>
        <div class="form-group col-md-2">
          <label for="zona">Zona</label>
          <input v-model="form.zona" id="zona" type="text" class="form-control" disabled />
        </div>
      </div>
      <div class="form-group mt-3">
        <button type="submit" class="btn btn-primary" :disabled="loading">Aplicar</button>
        <button type="button" class="btn btn-secondary ml-2" @click="onCancel">Salir</button>
      </div>
      <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
        {{ message }}
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'RNuevosPage',
  data() {
    return {
      form: {
        numero: '',
        letra: '',
        concesionario: '',
        ubicacion: 'RASTRO MUNICIPAL DE GUADALAJARA',
        superficie: '',
        licencia: '',
        tipo_local: '',
        aso: '',
        mes: '01',
        ofna: '5',
        sector: 'J',
        zona: '7'
      },
      tiposLocal: [],
      meses: [
        { value: '01', label: 'Enero' },
        { value: '02', label: 'Febrero' },
        { value: '03', label: 'Marzo' },
        { value: '04', label: 'Abril' },
        { value: '05', label: 'Mayo' },
        { value: '06', label: 'Junio' },
        { value: '07', label: 'Julio' },
        { value: '08', label: 'Agosto' },
        { value: '09', label: 'Septiembre' },
        { value: '10', label: 'Octubre' },
        { value: '11', label: 'Noviembre' },
        { value: '12', label: 'Diciembre' }
      ],
      loading: false,
      message: '',
      success: false
    };
  },
  created() {
    this.loadTiposLocal();
  },
  methods: {
    onlyDigits(e, maxLen) {
      if (!/[0-9]/.test(e.key) || (e.target.value.length >= maxLen && e.key !== 'Backspace')) {
        e.preventDefault();
      }
    },
    async loadTiposLocal() {
      // Fetch types of local from API
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'RNuevos.get_tipo_local', params: {} })
        });
        const data = await res.json();
        if (data.success && data.data.length > 0) {
          this.tiposLocal = data.data.map(row => row.descripcion);
          this.form.tipo_local = this.tiposLocal[0];
        } else {
          this.tiposLocal = ['INTERNO', 'EXTERNO'];
          this.form.tipo_local = 'INTERNO';
        }
      } catch (e) {
        this.tiposLocal = ['INTERNO', 'EXTERNO'];
        this.form.tipo_local = 'INTERNO';
      }
    },
    async onSubmit() {
      this.message = '';
      this.success = false;
      this.loading = true;
      // Validations
      if (!this.form.numero || this.form.numero === '0') {
        this.message = 'Falta el dato del NÚMERO DE LOCAL, intentalo de nuevo';
        this.loading = false;
        return;
      }
      // Check if control exists
      const control = this.form.numero + (this.form.letra ? '-' + this.form.letra : '');
      const checkRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'RNuevos.check_control', params: { control } })
      });
      const checkData = await checkRes.json();
      if (checkData.success && checkData.data.cnt > 0) {
        this.message = 'Ya existe LOCAL con este dato, intentalo de nuevo';
        this.loading = false;
        return;
      }
      if (!this.form.concesionario) {
        this.message = 'Falta el dato del CONCESIONARIO DEL LOCAL, intentalo de nuevo';
        this.loading = false;
        return;
      }
      if (!this.form.superficie || this.form.superficie === '0') {
        this.message = 'Falta el dato de la SUPERFICIE DEL LOCAL, intentalo de nuevo';
        this.loading = false;
        return;
      }
      if (!this.form.licencia) {
        this.message = 'Falta el dato de la LICENCIA DEL LOCAL, intentalo de nuevo';
        this.loading = false;
        return;
      }
      if (!this.form.aso || parseInt(this.form.aso) === 0) {
        this.message = 'Falta el dato del año, INTENTA DE NUEVO';
        this.loading = false;
        return;
      }
      const year = new Date().getFullYear();
      if (!(parseInt(this.form.aso) === year || parseInt(this.form.aso) === year - 1)) {
        this.message = 'Revisar el año de alta del LOCAL';
        this.loading = false;
        return;
      }
      // Call API to create
      const payload = {
        action: 'RNuevos.create',
        params: {
          par_tabla: '3',
          par_control: control,
          par_conces: this.form.concesionario,
          par_ubica: this.form.ubicacion,
          par_sup: parseFloat(this.form.superficie),
          par_Axo_Ini: parseInt(this.form.aso),
          par_Mes_Ini: parseInt(this.form.mes),
          par_ofna: parseInt(this.form.ofna),
          par_sector: this.form.sector,
          par_zona: parseInt(this.form.zona),
          par_lic: parseInt(this.form.licencia),
          par_Descrip: this.form.tipo_local
        }
      };
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        const data = await res.json();
        if (data.success && data.data && data.data[0] && data.data[0].expression === 0) {
          this.message = 'Se ejecutó correctamente la creación del Local/Concesión';
          this.success = true;
          this.resetForm();
        } else {
          this.message = data.data && data.data[0] ? data.data[0].expression_1 : (data.message || 'Error al grabar NUEVO Local/Concesión..');
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
        this.success = false;
      }
      this.loading = false;
    },
    onCancel() {
      this.$router.push('/');
    },
    resetForm() {
      this.form.numero = '';
      this.form.letra = '';
      this.form.concesionario = '';
      this.form.ubicacion = 'RASTRO MUNICIPAL DE GUADALAJARA';
      this.form.superficie = '';
      this.form.licencia = '';
      this.form.tipo_local = this.tiposLocal[0] || 'INTERNO';
      this.form.aso = '';
      this.form.mes = '01';
    }
  }
};
</script>

<style scoped>
.r-nuevos-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>

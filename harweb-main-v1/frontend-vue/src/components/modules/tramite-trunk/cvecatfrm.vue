<template>
  <div class="cvecat-page">
    <h1>Clave Catastral</h1>
    <div v-if="loading">Cargando...</div>
    <div v-else>
      <section class="datos-cuenta">
        <h2>Datos de la cuenta</h2>
        <div class="row">
          <label>Recaudadora:</label>
          <span>{{ convcta.recaud }}</span>
          <label>UrbRus:</label>
          <span>{{ convcta.urbrus }}</span>
          <label>Cuenta:</label>
          <span>{{ convcta.cuenta }}</span>
        </div>
        <div class="row">
          <label>Clave Catastral:</label>
          <span>{{ convcta.cvecatnva }}</span>
          <label>Subpredio:</label>
          <span>{{ convcta.subpredio }}</span>
          <label>Manzana:</label>
          <span>{{ convcta.cvemanz }}</span>
        </div>
      </section>
      <section class="propietario">
        <h2>Propietario</h2>
        <div class="row">
          <label>Nombre o razón social:</label>
          <span>{{ propietario.nombre_completo }}</span>
        </div>
        <div class="row">
          <label>Domicilio:</label>
          <span>{{ propietario.calle_vive }}</span>
        </div>
        <div class="row">
          <label>No. Exterior:</label>
          <span>{{ propietario.vive_ext }}</span>
          <label>No. Interior:</label>
          <span>{{ propietario.vive_int }}</span>
        </div>
      </section>
      <section class="ubicacion">
        <h2>Ubicación del predio</h2>
        <div class="row">
          <label>Calle:</label>
          <span>{{ ubicacion.calle }}</span>
          <label>No. ext.:</label>
          <span>{{ ubicacion.noexterior }}</span>
          <label>No. int.:</label>
          <span>{{ ubicacion.interior }}</span>
        </div>
      </section>
      <section class="nueva-clave">
        <h2>Nueva Clave Catastral</h2>
        <form @submit.prevent="onSubmit">
          <div class="row">
            <label>Clave catastral:</label>
            <input v-model="form.clave" maxlength="11" required />
            <label>Subpredio:</label>
            <input v-model="form.subpredio" type="number" min="0" max="999" />
          </div>
          <div class="row">
            <input type="checkbox" v-model="form.soloSubpredio" /> Cambiar solo subpredio
          </div>
          <div class="row">
            <button type="submit">Cambiar</button>
            <span v-if="formErrors.length" class="error-list">
              <ul>
                <li v-for="err in formErrors" :key="err">{{ err }}</li>
              </ul>
            </span>
            <span v-if="successMsg" class="success">{{ successMsg }}</span>
          </div>
        </form>
      </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CveCatPage',
  data() {
    return {
      loading: true,
      convcta: {},
      propietario: {},
      ubicacion: {},
      form: {
        clave: '',
        subpredio: '',
        soloSubpredio: false
      },
      formErrors: [],
      successMsg: '',
      cvecuenta: null,
      usuario: 'usuario_demo', // Debe obtenerse del contexto de login
      asiento: null,
      cvemov: null
    };
  },
  created() {
    // Suponemos que cvecuenta viene por ruta o contexto
    this.cvecuenta = this.$route.params.cvecuenta || 1;
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'getCveCatInfo',
          data: { cvecuenta: this.cvecuenta }
        })
      });
      const json = await res.json();
      if (json.status === 'ok') {
        this.convcta = json.data.convcta || {};
        this.propietario = json.data.propietario || {};
        this.ubicacion = json.data.ubicacion || {};
        this.form.clave = this.convcta.cvecatnva;
        this.form.subpredio = this.convcta.subpredio;
        this.asiento = this.convcta.asiento || 0;
        this.cvemov = this.convcta.cvemov || 0;
      }
      this.loading = false;
    },
    async onSubmit() {
      this.formErrors = [];
      this.successMsg = '';
      // Validar clave
      const valRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'validateCveCat',
          data: {
            clave: this.form.clave,
            subpredio: this.form.subpredio
          }
        })
      });
      const valJson = await valRes.json();
      if (!valJson.data.valid) {
        this.formErrors = valJson.data.errors;
        return;
      }
      // Checar manzana bloqueada
      const cvemanz = this.form.clave.substring(0, 8);
      const bloqueRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'checkBlockedManzana',
          data: { cvemanz }
        })
      });
      const bloqueJson = await bloqueRes.json();
      if (bloqueJson.data.blocked) {
        this.formErrors = ['No puedes modificar la clave catastral de esta cuenta porque la manzana está bloqueada'];
        return;
      }
      // Actualizar
      const updRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'updateCveCat',
          data: {
            cvecuenta: this.cvecuenta,
            clave: this.form.clave,
            subpredio: this.form.subpredio,
            usuario: this.usuario,
            observacion: `Cambio de clave catastral anterior: ${this.convcta.cvecatnva} Subp: ${this.convcta.subpredio}`,
            cvemov: this.cvemov,
            asiento: this.asiento + 1
          }
        })
      });
      const updJson = await updRes.json();
      if (updJson.status === 'ok' && updJson.data.success) {
        this.successMsg = 'Clave catastral actualizada correctamente';
        this.fetchData();
      } else {
        this.formErrors = updJson.errors || ['Error al actualizar'];
      }
    }
  }
};
</script>

<style scoped>
.cvecat-page {
  max-width: 800px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.row {
  display: flex;
  align-items: center;
  margin-bottom: 0.5em;
}
.row label {
  min-width: 120px;
  font-weight: bold;
}
.row input {
  margin-right: 1em;
  padding: 0.3em 0.5em;
}
.error-list {
  color: #b00;
  margin-left: 1em;
}
.success {
  color: #080;
  margin-left: 1em;
}
section {
  margin-bottom: 2em;
}
</style>

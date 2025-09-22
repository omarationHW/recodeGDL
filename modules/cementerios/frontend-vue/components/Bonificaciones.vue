<template>
  <div class="bonificaciones-page">
    <h1>Mantenimiento de Bonificaciones</h1>
    <div v-if="message" :class="{'alert-success': success, 'alert-danger': !success}" class="alert">{{ message }}</div>
    <form @submit.prevent="onBuscarOficio">
      <div class="form-row">
        <label>Oficio</label>
        <input v-model.number="form.oficio" type="number" required />
        <label>Año</label>
        <input v-model.number="form.axo" type="number" min="2000" max="2999" required />
        <label>Rec</label>
        <input v-model="form.doble" maxlength="1" required />
        <button type="submit">Buscar Oficio</button>
      </div>
    </form>
    <form @submit.prevent="onBuscarFolio" class="mt-2">
      <div class="form-row">
        <label>Folio</label>
        <input v-model.number="form.folio" type="number" required />
        <button type="submit">Verificar Folio</button>
      </div>
    </form>
    <div v-if="showPanel">
      <h2>Datos de la Fosa</h2>
      <div class="form-row">
        <label>Cementerio</label>
        <input :value="datosFosa.cementerio_nombre" disabled />
        <label>Clase</label>
        <input :value="datosFosa.clase" disabled />
        <label>Clase Alfa</label>
        <input :value="datosFosa.clase_alfa" disabled />
        <label>Sección</label>
        <input :value="datosFosa.seccion" disabled />
        <label>Sección Alfa</label>
        <input :value="datosFosa.seccion_alfa" disabled />
        <label>Línea</label>
        <input :value="datosFosa.linea" disabled />
        <label>Línea Alfa</label>
        <input :value="datosFosa.linea_alfa" disabled />
        <label>Fosa</label>
        <input :value="datosFosa.fosa" disabled />
        <label>Fosa Alfa</label>
        <input :value="datosFosa.fosa_alfa" disabled />
        <label>Nombre</label>
        <input :value="datosFosa.nombre" disabled />
      </div>
      <form @submit.prevent="onGuardar">
        <h2>Bonificación</h2>
        <div class="form-row">
          <label>Fecha Oficio</label>
          <input v-model="form.fecha_ofic" type="date" required />
          <label>Importe Total a Bonificar</label>
          <input v-model.number="form.importe_bonificar" type="number" step="0.01" required @blur="calcularPendiente" />
          <label>Importe Bonificado</label>
          <input v-model.number="form.importe_bonificado" type="number" step="0.01" required @blur="calcularPendiente" />
          <label>Importe Pendiente</label>
          <input :value="form.importe_resto" type="number" step="0.01" disabled />
        </div>
        <div class="form-row">
          <button type="submit">Guardar</button>
          <button v-if="bonificacionExiste" type="button" @click="onBorrar">Borrar</button>
          <button type="button" @click="onLimpiar">Limpiar</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BonificacionesPage',
  data() {
    return {
      form: {
        oficio: '',
        axo: new Date().getFullYear(),
        doble: '',
        folio: '',
        fecha_ofic: '',
        importe_bonificar: 0,
        importe_bonificado: 0,
        importe_resto: 0
      },
      datosFosa: {},
      bonificacionExiste: false,
      showPanel: false,
      message: '',
      success: true
    };
  },
  methods: {
    async onBuscarOficio() {
      this.message = '';
      // Buscar bonificación por oficio
      const res = await this.api('bonificaciones.getByOficio', {
        oficio: this.form.oficio,
        axo: this.form.axo,
        doble: this.form.doble
      });
      if (res.success && res.data.length > 0) {
        // Cargar datos en el formulario
        const bonif = res.data[0];
        this.form.fecha_ofic = bonif.fecha_ofic ? bonif.fecha_ofic.substr(0, 10) : '';
        this.form.importe_bonificar = bonif.importe_bonificar;
        this.form.importe_bonificado = bonif.importe_bonificado;
        this.form.importe_resto = bonif.importe_resto;
        this.form.folio = bonif.control_rcm;
        this.bonificacionExiste = true;
        this.showPanel = true;
        // Buscar datos de la fosa
        await this.onBuscarFolio();
      } else {
        this.message = 'No existe bonificación para ese oficio. Puede dar de alta.';
        this.bonificacionExiste = false;
        this.showPanel = false;
      }
    },
    async onBuscarFolio() {
      this.message = '';
      if (!this.form.folio) {
        this.message = 'Ingrese el número de folio';
        return;
      }
      const res = await this.api('bonificaciones.getByFolio', { folio: this.form.folio });
      if (res.success && res.data.length > 0) {
        this.datosFosa = res.data[0];
        this.showPanel = true;
      } else {
        this.message = 'No existe registro de fosa para ese folio';
        this.showPanel = false;
      }
    },
    calcularPendiente() {
      this.form.importe_resto = (parseFloat(this.form.importe_bonificar) || 0) - (parseFloat(this.form.importe_bonificado) || 0);
    },
    async onGuardar() {
      this.message = '';
      if (!this.form.importe_bonificar || this.form.importe_bonificar <= 0) {
        this.message = 'Error en el importe total a bonificar';
        this.success = false;
        return;
      }
      const payload = {
        oficio: this.form.oficio,
        axo: this.form.axo,
        doble: this.form.doble,
        control_rcm: this.form.folio,
        cementerio: this.datosFosa.cementerio,
        clase: this.datosFosa.clase,
        clase_alfa: this.datosFosa.clase_alfa,
        seccion: this.datosFosa.seccion,
        seccion_alfa: this.datosFosa.seccion_alfa,
        linea: this.datosFosa.linea,
        linea_alfa: this.datosFosa.linea_alfa,
        fosa: this.datosFosa.fosa,
        fosa_alfa: this.datosFosa.fosa_alfa,
        fecha_ofic: this.form.fecha_ofic,
        importe_bonificar: this.form.importe_bonificar,
        importe_bonificado: this.form.importe_bonificado,
        importe_resto: this.form.importe_resto
      };
      let res;
      if (!this.bonificacionExiste) {
        res = await this.api('bonificaciones.create', payload);
      } else {
        res = await this.api('bonificaciones.update', {
          oficio: this.form.oficio,
          axo: this.form.axo,
          doble: this.form.doble,
          fecha_ofic: this.form.fecha_ofic,
          importe_bonificar: this.form.importe_bonificar,
          importe_bonificado: this.form.importe_bonificado,
          importe_resto: this.form.importe_resto
        });
      }
      this.message = res.message;
      this.success = res.success;
      if (res.success) {
        this.bonificacionExiste = true;
      }
    },
    async onBorrar() {
      if (!confirm('¿Está seguro de borrar la bonificación?')) return;
      const res = await this.api('bonificaciones.delete', {
        oficio: this.form.oficio,
        axo: this.form.axo,
        doble: this.form.doble
      });
      this.message = res.message;
      this.success = res.success;
      if (res.success) {
        this.onLimpiar();
      }
    },
    onLimpiar() {
      this.form = {
        oficio: '',
        axo: new Date().getFullYear(),
        doble: '',
        folio: '',
        fecha_ofic: '',
        importe_bonificar: 0,
        importe_bonificado: 0,
        importe_resto: 0
      };
      this.datosFosa = {};
      this.bonificacionExiste = false;
      this.showPanel = false;
      this.message = '';
    },
    async api(action, params) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ action, params })
        });
        return await res.json();
      } catch (e) {
        return { success: false, message: e.message, data: null };
      }
    }
  }
};
</script>

<style scoped>
.bonificaciones-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  min-width: 120px;
  font-weight: bold;
}
.form-row input {
  min-width: 120px;
  padding: 0.3rem;
}
.alert {
  margin-bottom: 1rem;
  padding: 0.5rem 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #e6ffe6;
  color: #0a0;
}
.alert-danger {
  background: #ffe6e6;
  color: #a00;
}
.mt-2 {
  margin-top: 2rem;
}
</style>

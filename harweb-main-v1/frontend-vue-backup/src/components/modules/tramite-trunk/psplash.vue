<template>
  <div class="psplash-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Pantalla de Bienvenida</span>
    </div>
    <div class="splash-container">
      <div class="splash-panel">
        <img :src="splashInfo.image_url" class="splash-image" alt="Splash" />
        <div class="splash-bottom-bar">
          <div class="splash-label-left">
            <span class="welcome-text">¡¡¡¡¡¡¡¡ BIENVENIDOS !!!!!!!!<br/>Cargando Aplicación</span>
          </div>
          <div class="splash-label-right">
            <span class="tramite-text">TRAMITE<br/>Versión {{ splashInfo.version }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PsplashPage',
  data() {
    return {
      splashInfo: {
        image_url: '',
        version: '',
        copyright: ''
      },
      loading: true,
      error: null
    };
  },
  created() {
    this.fetchSplashInfo();
  },
  methods: {
    async fetchSplashInfo() {
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: 'psplash.getSplashInfo',
          params: {}
        });
        if (response.data.success) {
          this.splashInfo = response.data.data;
        } else {
          this.error = response.data.message || 'Error al cargar información de bienvenida';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.psplash-page {
  background: #f5f5f5;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
.breadcrumb {
  margin: 16px 0 0 32px;
  font-size: 14px;
  color: #888;
}
.splash-container {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}
.splash-panel {
  width: 484px;
  height: 356px;
  background: #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.15);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.splash-image {
  width: 100%;
  height: 307px;
  object-fit: cover;
  background: #333;
}
.splash-bottom-bar {
  display: flex;
  flex-direction: row;
  align-items: stretch;
  background: #800000;
  color: #fff;
  height: 49px;
  width: 100%;
  position: absolute;
  bottom: 0;
  left: 0;
  border-top: 2px solid #fff;
}
.splash-label-left {
  flex: 1;
  display: flex;
  align-items: center;
  padding-left: 16px;
}
.splash-label-right {
  width: 140px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 16px;
}
.welcome-text {
  font-family: Arial, sans-serif;
  font-size: 16px;
  color: #fff;
  text-shadow: 1px 1px 2px #000;
  line-height: 1.2;
}
.tramite-text {
  font-family: 'Arial Narrow', Arial, sans-serif;
  font-size: 15px;
  color: #FFD700;
  font-weight: bold;
  text-shadow: 1px 1px 2px #000;
  text-align: right;
  line-height: 1.2;
}
</style>
